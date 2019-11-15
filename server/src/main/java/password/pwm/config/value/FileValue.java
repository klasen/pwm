/*
 * Password Management Servlets (PWM)
 * http://www.pwm-project.org
 *
 * Copyright (c) 2006-2009 Novell, Inc.
 * Copyright (c) 2009-2019 The PWM Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package password.pwm.config.value;

import lombok.Builder;
import lombok.Value;
import password.pwm.PwmConstants;
import password.pwm.config.PwmSetting;
import password.pwm.config.StoredValue;
import password.pwm.error.PwmOperationalException;
import password.pwm.error.PwmUnrecoverableException;
import password.pwm.http.bean.ImmutableByteArray;
import password.pwm.util.java.JsonUtil;
import password.pwm.util.java.StringUtil;
import password.pwm.util.java.XmlElement;
import password.pwm.util.java.XmlFactory;
import password.pwm.util.logging.PwmLogger;
import password.pwm.util.secure.PwmHashAlgorithm;
import password.pwm.util.secure.PwmSecurityKey;
import password.pwm.util.secure.SecureEngine;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

public class FileValue extends AbstractValue implements StoredValue
{
    private static final PwmLogger LOGGER = PwmLogger.forClass( FileValue.class );

    private static final int ENCODING_LINE_LENGTH = 120;

    private final Map<FileInformation, FileContent> values;

    @Value
    public static class FileInformation implements Serializable
    {
        private String filename;
        private String filetype;
   }

    @Value
    public static class FileContent implements Serializable
    {
        private ImmutableByteArray contents;


        public static FileContent fromEncodedString( final String input )
                throws IOException
        {
            final byte[] convertedBytes = StringUtil.base64Decode( input );
            return new FileContent( ImmutableByteArray.of( convertedBytes ) );
        }

        public String toEncodedString( )
                throws IOException
        {
            return StringUtil.base64Encode( contents.copyOf(), StringUtil.Base64Options.GZIP );
        }

        public String sha512sum( )
                throws PwmUnrecoverableException
        {
            return SecureEngine.hash( new ByteArrayInputStream( contents.copyOf() ), PwmHashAlgorithm.SHA512 );
        }

        public int size( )
        {
            return contents.copyOf().length;
        }
    }

    public FileValue( final Map<FileInformation, FileContent> values )
    {
        this.values = values == null ? Collections.emptyMap() : values;
    }

    public static StoredValueFactory factory( )
    {
        return new StoredValueFactory()
        {

            public FileValue fromXmlElement( final PwmSetting pwmSetting, final XmlElement settingElement, final PwmSecurityKey input )
                    throws PwmOperationalException
            {
                final List<XmlElement> valueElements = settingElement.getChildren( "value" );
                final Map<FileInformation, FileContent> values = new LinkedHashMap<>();
                for ( final XmlElement loopValueElement : valueElements )
                {
                    final Optional<XmlElement> loopFileInformation = loopValueElement.getChild( "FileInformation" );
                    if ( loopFileInformation.isPresent() )
                    {
                        final String loopFileInformationJson = loopFileInformation.get().getText();
                        final FileInformation fileInformation = JsonUtil.deserialize( loopFileInformationJson,
                                FileInformation.class );

                        final Optional<XmlElement> loopFileContentElement = loopValueElement.getChild( "FileContent" );
                        if ( loopFileContentElement.isPresent() )
                        {
                            final String fileContentString = loopFileContentElement.get().getText();
                            final FileContent fileContent;
                            try
                            {
                                fileContent = FileContent.fromEncodedString( fileContentString );
                                values.put( fileInformation, fileContent );
                            }
                            catch ( final IOException e )
                            {
                                LOGGER.error( "error reading file contents item: " + e.getMessage(), e );
                            }
                        }
                    }
                }
                return new FileValue( values );
            }

            public StoredValue fromJson( final String input )
            {
                throw new IllegalStateException( "not implemented" );
            }
        };
    }

    public List<XmlElement> toXmlValues( final String valueElementName, final OutputConfiguration outputConfiguration )
    {
        final List<XmlElement> returnList = new ArrayList<>();
        for ( final Map.Entry<FileInformation, FileContent> entry : this.values.entrySet() )
        {
            final FileValue.FileInformation fileInformation = entry.getKey();
            final FileContent fileContent = entry.getValue();
            final XmlElement valueElement = XmlFactory.getFactory().newElement( valueElementName );

            final XmlElement fileInformationElement = XmlFactory.getFactory().newElement( "FileInformation" );
            fileInformationElement.addText( JsonUtil.serialize( fileInformation ) );
            valueElement.addContent( fileInformationElement );

            final XmlElement fileContentElement = XmlFactory.getFactory().newElement( "FileContent" );
            //final String encodedLineBreaks = StringUtil.insertineBreaks( fileContent.toEncodedString(), ENCODING_LINE_LENGTH );
            try
            {
                fileContentElement.addText( fileContent.toEncodedString() );
            }
            catch ( final IOException e )
            {
                LOGGER.error( "unexpected error writing setting to xml, IO error during base64 encoding: " + e.getMessage() );
            }
            valueElement.addContent( fileContentElement );

            returnList.add( valueElement );
        }
        return returnList;
    }

    @Override
    public Object toNativeObject( )
    {
        return values;
    }

    @Override
    public List<String> validateValue( final PwmSetting pwm )
    {
        return Collections.emptyList();
    }

    @Override
    public String toDebugString(
            final Locale locale
    )
    {
        final List<Map<String, Object>> output = asMetaData();
        return JsonUtil.serialize( ( Serializable ) output, JsonUtil.Flag.PrettyPrint );
    }

    @Override
    public Serializable toDebugJsonObject( final Locale locale )
    {
        return ( Serializable ) asMetaData();
    }

    public List<Map<String, Object>> asMetaData( )
    {
        final List<Map<String, Object>> output = new ArrayList<>();
        for ( final Map.Entry<FileInformation, FileContent> entry : this.values.entrySet() )
        {
            final FileValue.FileInformation fileInformation = entry.getKey();
            final FileContent fileContent = entry.getValue();
            final Map<String, Object> details = new LinkedHashMap<>();
            details.put( "name", fileInformation.getFilename() );
            details.put( "type", fileInformation.getFiletype() );
            details.put( "size", fileContent.size() );
            try
            {
                details.put( "sha512sum", fileContent.sha512sum() );
            }
            catch ( final PwmUnrecoverableException e )
            {
                LOGGER.trace( () -> "error generating file hash" );
            }
            output.add( details );
        }
        return output;
    }

    public List<FileInfo> toInfoMap( )
    {
        if ( values == null )
        {
            return Collections.emptyList();
        }
        final List<FileInfo> returnObj = new ArrayList<>();
        for ( final Map.Entry<FileInformation, FileContent> entry : this.values.entrySet() )
        {
            final FileValue.FileInformation fileInformation = entry.getKey();
            final FileContent fileContent = entry.getValue();
            try
            {
                returnObj.add( FileInfo.builder()
                        .name( fileInformation.getFilename() )
                        .type( fileInformation.getFiletype() )
                        .size( fileContent.size() )
                        .sha512sum( fileContent.sha512sum() )
                        .build() );
            }
            catch ( final PwmUnrecoverableException e )
            {
                throw new IllegalStateException( e );
            }
        }
        return Collections.unmodifiableList( returnObj );
    }

    protected String valueHashImpl()
    {
        try
        {
            return SecureEngine.hash( JsonUtil.serializeCollection( toInfoMap() ), PwmConstants.SETTING_CHECKSUM_HASH_METHOD );
        }
        catch ( final PwmUnrecoverableException e )
        {
            throw new IllegalStateException( e );
        }
    }

    @Value
    @Builder
    public static class FileInfo implements Serializable
    {
        private String name;
        private String type;
        private long size;
        private String sha512sum;
    }
}
