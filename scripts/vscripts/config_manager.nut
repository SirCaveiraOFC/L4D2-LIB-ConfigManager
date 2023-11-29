/**
 * Copyright © 2023 Sr.Caveira | 頭蓋骨 </> Dark'
 *
 * All rights reserved.
 *
 * This add-on, "[LIB] Config Manager," is the intellectual property of the modder,
 * Sr.Caveira | 頭蓋骨 </> Dark'.
 *
 * This add-on is protected by international copyright laws
 * as well as other intellectual property laws and treaties.
 *
 * Unauthorized modifying of this add-on or any portion of it may result in severe
 * civil and criminal penalties on Steam and Real Life.
 *
 * Permission is hereby granted for personal, non-commercial use only.
 * Users are prohibited from modifying this add-on.
 * Any such unauthorized activities are strictly prohibited and may violate the rights of the modder.
 *
 * This add-on is provided "as is" without any warranties, express or implied.
 *
 * For any inquiries or permission requests, please contact srcaveiraoficial@gmail.com.
 */

Msg("[Config Manager] Loading [LIB] Config Manager...\n");

// Include the VScript Library
IncludeScript("config_manager/VSLib");

// "CM" = Config Manager (to prevent conflict with other add-ons)

::CM_DebugMessage                           <- "";

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Prints a message to the Host Player.
 */
::CM_PrintToHost                            <- function( Message )
{
  foreach ( survivor in Players.Survivors() )
  {
    if ( survivor.IsHuman() )
    {
      local IsHostPlayer = GetPlayerFromUserID( survivor.GetUserID() ) == GetListenServerHost();

      if ( IsHostPlayer )
      {
        survivor.Print( Message );
        break;
      }
    }
  }
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Converts a string, e.g. "true"; to a real bool; true.
 */
::CM_ToBool                                 <- function( String )
{
  local String = String.tolower();

  if ( String == "true" )
    return true;
  else if ( String == "false" )
    return false;

  return null;
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Converts a non-real value, e.g. "true"; to a real value; true.
 */
::CM_ConvertValueType                       <- function( Value, ValueType )
{
  switch ( ValueType )
  {
    case "string":
    {
      return Value.tostring();
      break;
    }

    case "integer":
    {
      return Value.tointeger();
      break;
    }

    case "float":
    {
      return Value.tofloat();
      break;
    }

    case "bool":
    {
      return ::CM_ToBool( Value );
      break;
    }
  }
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @info      Config Manager Table to store all Functions and Variables.
 */
::CM_ConfigManager                          <- {};

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Validates a String Parameter.
 *
 * @param     {string}  ParameterValue  - The ParameterValue, e.g.  "FileFolder".
 * @param     {string}  ParameterName   - The ParameterName,  e.g.  "FileFolder"
 * @param     {string}  FunctionName    - The FunctionName,   e.g.  "CM_ConfigManager.Create()"
 *
 * @usages
 * Examples:
 * ::CM_ConfigManager.ValidateStringParameter( FileFolder, "FileFolder", "CM_ConfigManager.Create()" );
 * ::CM_ConfigManager.ValidateStringParameter( FileName,   "FileName",   "CM_ConfigManager.Create()" );
 * ::CM_ConfigManager.ValidateStringParameter( FileType,   "FileType",   "CM_ConfigManager.Create()" );
 *
 * @throws    {string}  If any of the parameters aren't an non-empty string.
 */
::CM_ConfigManager.ValidateStringParameter  <- function( ParameterValue, ParameterName, FunctionName )
{
  // Check if ParameterValue is valid non-empty string.
  if ( ParameterValue == "" || ( typeof ParameterValue ) != "string" )
  {
    ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The '" + ParameterName + "' parameter must be a non-empty string.";
    ::CM_PrintToHost( ::CM_DebugMessage );
    throw ::CM_DebugMessage;
  }
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Check if FileValueType is one of the valid types.
 *
 * @param     {string}  FileValueType - The FileValueType,  e.g.  "table".
 * @param     {string}  ParameterName - The ParameterName,  e.g.  "FileValue"
 * @param     {string}  FunctionName  - The FunctionName,   e.g.  "CM_ConfigManager.Create()"
 *
 * @usages
 * Examples:
 * ::CM_ConfigManager.ValidateFileValueType( FileValueType, "FileValue", "CM_ConfigManager.Create()" );
 *
 * @throws    {string}  If the FileValueType parameter isn't one of the valid types.
 */
::CM_ConfigManager.ValidateFileValueType    <- function( FileValueType, ParameterName, FunctionName )
{
  if
  (
    FileValueType != "string"   &&
    FileValueType != "integer"  &&
    FileValueType != "float"    &&
    FileValueType != "bool"     &&
    FileValueType != "table"    &&
    FileValueType != "array"
  )
  {
    ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : Parameter '" + ParameterName + "' cannot be a '" + FileValueType + "'.";
    ::CM_PrintToHost( ::CM_DebugMessage );
    throw ::CM_DebugMessage;
  }
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Check if FileType and FileValueType is or not incompatible.
 *
 * @param     {string}  FileType      - The FileType,       e.g.  "KeyValue".
 * @param     {string}  FileValueType - The FileValueType,  e.g.  "FileValueType" -> string | integer | etc...
 * @param     {string}  FunctionName  - The FunctionName,   e.g.  "CM_ConfigManager.Create()"
 *
 * @usages
 * Examples:
 * ::CM_ConfigManager.ValidateFileType( "KeyValue", FileValueType,  "CM_ConfigManager.Create()" );
 * ::CM_ConfigManager.ValidateFileType( "List",     FileValueType,  "CM_ConfigManager.Create()" );
 * ::CM_ConfigManager.ValidateFileType( "CVar",     FileValueType,  "CM_ConfigManager.Create()" );
 *
 * @throws    {string}  if FileType and FileValueType is or not incompatible/invalid.
 */
::CM_ConfigManager.ValidateFileType         <- function( FileType, FileValueType, FunctionName )
{
  if ( FileType != "KeyValue" && FileType != "List" && FileType != "CVar" )
  {
    ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : Invalid parameter! Parameter 'FileType' cannot be '" + FileType + "'.";
    ::CM_PrintToHost( ::CM_DebugMessage );
    throw ::CM_DebugMessage;
  }

  if ( FileType == "KeyValue" && FileValueType != "table" )
  {
    ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : Incompatible parameters! Parameter 'FileType' needs the parameter 'FileValue' as a 'table'.";
    ::CM_PrintToHost( ::CM_DebugMessage );
    throw ::CM_DebugMessage;
  }
  else if ( FileType == "List" && FileValueType != "array" )
  {
    ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : Incompatible parameters! Parameter 'FileValue' cannot be a '" + FileValueType + "' when parameter 'FileType' is 'List'.";
    ::CM_PrintToHost( ::CM_DebugMessage );
    throw ::CM_DebugMessage;
  }
  else if ( FileType == "CVar" )
  {
    if
    (
      FileValueType != "string"   &&
      FileValueType != "integer"  &&
      FileValueType != "float"    &&
      FileValueType != "bool"
    )
    {
      ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : Incompatible parameters! Parameter 'FileValue' cannot be a '" + FileValueType + "' when parameter 'FileType' is 'CVar'.";
      ::CM_PrintToHost( ::CM_DebugMessage );
      throw ::CM_DebugMessage;
    }
  }
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Creates a Config File.
 *
 * @info      {any}     = {string|integer|float|bool|table|array}
 *
 * @param     {string}  FileFolder  - The Folder Name,  e.g. "cm_config_manager".
 * @param     {string}  FileName    - The File Name,    e.g. "config_manager_settings".
 * @param     {string}  FileType    - The File Type, either "KeyValue" or "List" or "CVar".
 * @param     {any}     FileValue   - The value to be written into the file.
 *
 * @usages
 * Examples:
 * ::CM_ConfigManager.Create( "cm_config_manager", "config_manager_settings", "KeyValue", { IsEnabled = true } );
 * ::CM_ConfigManager.Create( "cm_config_manager", "banned_players", "List", [ "Player1", "Player2" ] );
 * ::CM_ConfigManager.Create( "cm_config_manager", "config_manager_enabled", "CVar", true );
 *
 * @throws    {string}  If any of the parameters are invalid or incompatible.
 *
 * @returns   {bool}    Returns true if the file was created successfully, or false if it already exists.
 *
 * @warning
 * Please use this function with caution.
 * Once a file and/or folder is created, it cannot be deleted.
 * Make sure before creating it.
 */
::CM_ConfigManager.Create                   <- function( FileFolder, FileName, FileType, FileValue )
{
  local FullPath        = FileFolder + "/" + FileName + ".txt";
  local File            = FileToString( FullPath );
  local FileContents    = "";
  local Delimiter       = "=";
  local Delimiter2      = "|";
  local FileValueType   = ( typeof FileValue );
  local ValueCount      = 0;
  local ValueTempCount  = 0;
  local ValueType       = null;
  local FunctionName    = "CM_ConfigManager.Create()";

  // Check if FileFolder, FileName and FileType are valid non-empty strings.
  ::CM_ConfigManager.ValidateStringParameter( FileFolder, "FileFolder", FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileName,   "FileName",   FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileType,   "FileType",   FunctionName );

  // Check if FileValueType is one of the valid types.
  ::CM_ConfigManager.ValidateFileValueType( FileValueType, "FileValue", "CM_ConfigManager.Create()" );

  // Check if FileType is or not invalid.
  ::CM_ConfigManager.ValidateFileType( FileType, FileValueType, FunctionName );

  // Check if the file doesn't exist.
  if ( File == null )
  {
    switch ( FileType )
    {
      case "KeyValue":
      {
        ValueCount      = FileValue.len();
        ValueTempCount  = ValueCount;

        // Check if there's no KeyValue pairs to add
        if ( ValueCount <= 0 )
          break;

        foreach ( key, value in FileValue )
        {
          ValueType = ( typeof value );

          // Check if there's multiple KeyValue pairs
          if ( ValueCount >= 2 )
          {
            FileContents += key + Delimiter + value + Delimiter2 + ValueType;

            ValueTempCount--;

            // Check if there's more KeyValue pairs to add; then add "\n" if there's
            if ( ValueTempCount > 0 )
              FileContents += "\n";
            else
              break;
          }
          else
          {
            FileContents = key + Delimiter + value + Delimiter2 + ValueType;
            break;
          }
        }
        break;
      }

      case "List":
      {
        ValueCount      = FileValue.len();
        ValueTempCount  = ValueCount;

        // Check if there are no value pairs to add
        if ( ValueCount <= 0 )
          break;

        foreach ( value in FileValue )
        {
          ValueType = ( typeof value );

          // Check if there's multiple value pairs
          if ( ValueCount >= 2 )
          {
            FileContents += value + Delimiter2 + ValueType;

            ValueTempCount--;

            // Check if there's more Values to add; then add "\n" if there's
            if ( ValueTempCount > 0 )
              FileContents += "\n";
            else
              break;
          }
          else
          {
            FileContents = value + Delimiter2 + ValueType;
          }
        }
        break;
      }

      case "CVar":
      {
        ValueType = ( typeof FileValue );

        if ( FileValue == "" )
          break;

        FileContents = FileValue + Delimiter2 + ValueType;
        break;
      }
    }

    /**
     * If the file doesn't exist,
     * try to create it and return true to indicate success and false to indicate fail.
     */
    local TryToCreateConfigFile = StringToFile( FullPath, FileContents );

    if ( TryToCreateConfigFile )
      return true;

    return false;
  }

  /**
   * If the file already exists or occour an error when tried to create the file,
   * return false to indicate that it couldn't be created.
   */
  return false;
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Updates a Config File.
 *
 * @info      {any}     = {string|integer|float|bool|table|array}
 *
 * @param     {string}  FileFolder    - The Folder Name,  e.g. "cm_config_manager".
 * @param     {string}  FileName      - The File Name,    e.g. "config_manager_settings".
 * @param     {string}  FileType      - The File Type, either "KeyValue" or "List" or "CVar".
 * @param     {string}  FileOldValue  - The old value to be searched into the file.
 * @param     {any}     FileNewValue  - The new value to replace the old value into the file
 *
 * @usages    ::CM_ConfigManager.Update( "cm_config_manager", "config_manager_configs", "KeyValue", "IsAdminOnly", false );
 *            ::CM_ConfigManager.Update( "cm_config_manager", "config_manager_players", "List", "Player1", "PlayerOne" );
 *            ::CM_ConfigManager.Update( "cm_config_manager", "config_manager_enabled", "CVar", "", true );
 *
 * @warning             If the parameter 'FileType' is 'CVar', leave the parameter "FileOldValue" as an empty string "".
 *
 * @throws    {string}  If any of the parameters are invalid or incompatible,
 *                      if the file doesn't exist, if the file is missing something and so on.
 *
 * @returns   {bool}    Returns true if the file was updated successfully, or false if it couldn't.
 */
::CM_ConfigManager.Update                   <- function( FileFolder, FileName, FileType, FileOldValue, FileNewValue )
{
  local FullPath          = FileFolder + "/" + FileName + ".txt";
  local File              = FileToString( FullPath );
  local FileOldContents   = "";
  local FileNewContents   = "";
  local NewContents       = "";
  local Delimiter         = "=";
  local Delimiter2        = "|";
  local FileOldValueType  = ( typeof FileOldValue );
  local FileNewValueType  = ( typeof FileNewValue );
  local Key               = null;
  local OldValue          = null;
  local OldValueType      = null;
  local NewValue          = null;
  local NewValueType      = null;
  local CurrentLine       = 0;
  local FileOldValueFound = false;
  local FunctionName      = "CM_ConfigManager.Update()";

  // Check if FileFolder, FileName and FileType are valid non-empty strings.
  ::CM_ConfigManager.ValidateStringParameter( FileFolder, "FileFolder", FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileName,   "FileName",   FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileType,   "FileType",   FunctionName );

  // Check if FileOldValueType isn't a String.
  if ( FileOldValueType != "string" )
  {
    ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : Incompatible parameters! Parameter 'FileOldValue' cannot be '" + FileOldValueType + "'.";
    ::CM_PrintToHost( ::CM_DebugMessage );
    throw ::CM_DebugMessage;
  }

  // Check if FileNewValueType is or not invalid.
  if
  (
    FileNewValueType != "string"   &&
    FileNewValueType != "integer"  &&
    FileNewValueType != "float"    &&
    FileNewValueType != "bool"
  ) {
    ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : Parameter '" + "FileNewValue" + "' cannot be a '" + FileNewValueType + "'.";
    ::CM_PrintToHost( ::CM_DebugMessage );
    throw ::CM_DebugMessage;
  }

  // Check if the file exist.
  if ( File != null )
  {
   FileOldContents = split( strip( File ), "\n" );

   switch ( FileType )
   {
     case "KeyValue":
     {
       foreach ( Line in FileOldContents )
       {
         CurrentLine++;

         // Check if FileOldContents contains the "=" delimiter.
         if ( Line.find( Delimiter ) != null )
         {
           local LineSplitEqual = split( Line, Delimiter );

           // Check if FileOldContents contains the "|" delimiter.
           if ( Line.find( Delimiter2 ) != null )
           {
             /**
              * Check if is or not missing the 'Value' OR 'ValueType'
              */
             if ( split( Line, Delimiter2 ).len() != 2 )
             {
               ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
               ::CM_PrintToHost( ::CM_DebugMessage );
               throw ::CM_DebugMessage;
             }

             /**
              * Check if the FileOldValue has been found and set it as true.
              */
             if ( Line.find( FileOldValue ) != null )
             {
              FileOldValueFound = true;
             }

             Key               = LineSplitEqual[0];
             OldValue          = split( LineSplitEqual[1], Delimiter2 )[0];
             OldValueType      = split( LineSplitEqual[1], Delimiter2 )[1];

             /**
              * Check if didn't found the 'FileNewValue' in the config file
              * and set 'FileNewContents' as an empty string to indicates it not found.
              */
             if ( CurrentLine == FileOldContents.len() && !FileOldValueFound )
             {
              FileNewContents = "";
              break;
             }

             /**
              * Check if the 'FileOldValue' has been found.
              * If found, set the new values.
              */
             if ( FileOldValueFound )
             {
              NewValue        = ::Utils.StringReplace( OldValue, OldValue, FileNewValue.tostring() );
              NewValueType    = ::Utils.StringReplace( OldValueType, OldValueType, FileNewValueType );
					    NewContents     = Key + Delimiter + NewValue + Delimiter2 + NewValueType;

              if ( FileNewContents != "" )
              {
                FileNewContents = FileNewContents + "\n";
              }

              FileNewContents = FileNewContents + NewContents;
             }
             else
             {
              if ( FileNewContents != "" )
              {
                FileNewContents = FileNewContents + "\n";
              }

              FileNewContents = FileNewContents + Line;
             }
           }
           else
           {
             ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
             ::CM_PrintToHost( ::CM_DebugMessage );
             throw ::CM_DebugMessage;
           }
         }
         else
         {
           ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter + "' delimiter on line '" + CurrentLine + "'.";
           ::CM_PrintToHost( ::CM_DebugMessage );
           throw ::CM_DebugMessage;
         }
       }
       break;
     }

     case "List":
     {
       foreach ( Line in FileOldContents )
       {
         CurrentLine++;

         local LineSplitVerticalBar = split( Line, Delimiter2 );

         // Check if FileOldContents contains the "|" delimiter.
         if ( Line.find( Delimiter2 ) != null )
         {
          /**
           * Check if is or not missing the 'Value' OR 'ValueType'
           */
          if ( split( Line, Delimiter2 ).len() != 2 )
          {
            ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
            ::CM_PrintToHost( ::CM_DebugMessage );
            throw ::CM_DebugMessage;
          }

          /**
           * Check if the FileOldValue has been found and set it as true.
           */
          if ( Line.find( FileOldValue ) != null )
          {
             FileOldValueFound = true;
          }

          OldValue          = LineSplitVerticalBar[0];
          OldValueType      = LineSplitVerticalBar[1];
          FileOldValueFound = true;

          if ( CurrentLine == FileOldContents.len() && !FileOldValueFound )
          {
           FileNewContents = "";
           break;
          }

          if ( FileOldValueFound )
          {
           NewValue        = ::StringReplace( OldValue, OldValue, FileNewValue.tostring() );
           NewValueType    = ::StringReplace( OldValueType, OldValueType, FileNewValueType );
           NewContents     = NewValue + Delimiter2 + NewValueType;

           if ( FileNewContents != "" )
           {
             FileNewContents = FileNewContents + "\n";
           }

					 FileNewContents = FileNewContents + NewContents;
          }
          else
          {
           if ( FileNewContents != "" )
           {
             FileNewContents = FileNewContents + "\n";
           }

           FileNewContents = FileNewContents + Line;
          }
         }
         else
         {
           ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
           ::CM_PrintToHost( ::CM_DebugMessage );
           throw ::CM_DebugMessage;
         }
       }
       break;
     }

     case "CVar":
     {
       // Save the original file contents to FileOldContents.
       FileOldContents = File;

       // Check if FileOldContents contains the "|" delimiter.
       if ( FileOldContents.find( Delimiter2 ) != null )
       {
         // Split the contents using "|" as a delimiter.
         FileOldContents = split( FileOldContents, Delimiter2 );

         // Check if there are two parts after splitting.
         if ( FileOldContents.len() == 2 )
         {
           // Extract and store the old value and old value type.
           OldValue        = FileOldContents[0];
           OldValueType    = strip( FileOldContents[1] );

           // Generate new values for FileNewContents.
           NewValue        = Utils.StringReplace( OldValue, OldValue, FileNewValue.tostring() );
           NewValueType    = Utils.StringReplace( OldValueType, OldValueType, FileNewValueType );

           // Combine the new values into FileNewContents.
           FileNewContents = NewValue + Delimiter2 + NewValueType;

           if ( FileOldContents.find( FileNewContents ) != null )
           {
            FileNewContents = "";
            break;
           }
           break;
         }
         else
         {
           ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType'.";
           ::CM_PrintToHost( ::CM_DebugMessage );
           throw ::CM_DebugMessage;
         }
       }
       else
       {
         ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter.";
         ::CM_PrintToHost( ::CM_DebugMessage );
         throw ::CM_DebugMessage;
       }
       break;
     }
   }

   /**
    * Check if there are new contents to update.
    * If there are, return true; otherwise, will return false.
    */
   if ( FileNewContents != "" )
   {
     /**
      * If the file exists,
      * try to update his data and return true to indicate success.
      */
     local TryToUpdateConfigFile = StringToFile( FullPath, strip( FileNewContents ) );

     if ( TryToUpdateConfigFile )
        return true;

     return false;
   }

   return false;
  }

  /**
   * If the file doesn't exist, return false and print a DebugMessage
   * to indicate that it couldn't be updated.
   */
  ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' doesn't exist.";
  ::CM_PrintToHost( ::CM_DebugMessage );

  return false;
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Adds data into a Config File.
 *
 * @info      {any}     = {string|integer|float|bool|table|array}
 *
 * @param     {string}  FileFolder    - The Folder Name,  e.g. "cm_config_manager".
 * @param     {string}  FileName      - The File Name,    e.g. "config_manager_settings".
 * @param     {string}  FileType      - The File Type, either "KeyValue" or "List" or "CVar".
 * @param     {any}     FileValue     - The value to be added into the file.
 *
 * @usages
 * Examples:
 * ::CM_ConfigManager.Add( "cm_config_manager", "config_manager_configs", "KeyValue", { IsAdminOnly = true } );
 * ::CM_ConfigManager.Add( "cm_config_manager", "config_manager_players", "List", [ "Player1", "PlayerOne" ] );
 * ::CM_ConfigManager.Add( "cm_config_manager", "config_manager_enabled", "CVar", true );
 *
 * @throws    {string}  If any of the parameters are invalid or incompatible,
 *                      if the file doesn't exist, if the file is missing something and so on.
 *
 * @returns   {bool}    Returns true if the data was added into the file successfully, or false if it couldn't.
 */
::CM_ConfigManager.Add                      <- function( FileFolder, FileName, FileType, FileValue )
{
  local FullPath          = FileFolder + "/" + FileName + ".txt";
  local File              = FileToString( FullPath );
  local FileOldContents   = "";
  local FileNewContents   = "";
  local Delimiter         = "=";
  local Delimiter2        = "|";
  local FileValueType     = ( typeof FileValue );
  local CurrentLine       = 0;
  local NewValue          = null;
  local NewValueCount     = 0;
  local NewValueTempCount = 0;
  local NewValueType      = null;
  local FunctionName      = "CM_ConfigManager.Add()";

  // Check if FileFolder, FileName and FileType are valid non-empty strings.
  ::CM_ConfigManager.ValidateStringParameter( FileFolder, "FileFolder", FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileName,   "FileName",   FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileType,   "FileType",   FunctionName );

  // Check if FileValue is or not invalid.
  ::CM_ConfigManager.ValidateFileValueType( FileValueType, "FileValue", FunctionName );

  // Check if FileType is or not invalid.
  ::CM_ConfigManager.ValidateFileType( FileType, FileValueType, FunctionName );

  // Check if the file exist.
  if ( File != null )
  {
   FileOldContents = split( strip( File ), "\n" );

   switch ( FileType )
   {
     case "KeyValue":
     {
       NewValueCount      = FileValue.len();
       NewValueTempCount  = NewValueCount;

       // Check if there's no KeyValue pairs to add
       if ( NewValueCount <= 0 )
       {
         ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The Table in Parameter 'FileValue' is empty.";
         ::CM_PrintToHost( ::CM_DebugMessage );
         throw ::CM_DebugMessage;
       }

       // Check if the file isn't empty.
       if ( strip( File ) != "" )
       {
         foreach ( Line in FileOldContents )
         {
           CurrentLine++;

           // Check if this line in FileOldContents contains the "=" delimiter.
           if ( Line.find( Delimiter ) != null )
           {
             // Check if this line in FileOldContents contains the "|" delimiter.
             if ( Line.find( Delimiter2 ) != null )
             {
               /**
                * Check if is missing the 'Value' OR 'ValueType'
                **/
               if ( split( Line, Delimiter2 ).len() != 2 )
               {
                 ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
                 ::CM_PrintToHost( ::CM_DebugMessage );
                 throw ::CM_DebugMessage;
               }

               FileNewContents += Line + "\n";
             }
             else
             {
               ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
               ::CM_PrintToHost( ::CM_DebugMessage );
               throw ::CM_DebugMessage;
             }
           }
           else
           {
             ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter + "' delimiter on line '" + CurrentLine + "'.";
             ::CM_PrintToHost( ::CM_DebugMessage );
             throw ::CM_DebugMessage;
           }
         }
         CurrentLine = 0;
       }

       // Get and store the new value contents.
       foreach ( key, value in FileValue )
       {
         // Remove all white-space and/or "\n".
         FileNewContents = strip( FileNewContents );

         NewValueType  = ( typeof value );
         NewValue      = key + Delimiter + value + Delimiter2 + NewValueType;

         if ( FileNewContents.find( NewValue ) == null )
         {
           // Check if there's multiple KeyValue pairs.
           if ( NewValueCount >= 2 )
           {
             FileNewContents += "\n" + NewValue;

             NewValueTempCount--;

             // Check if there's more KeyValue pairs to add; then add "\n" if there's.
             if ( NewValueTempCount > 0 )
               FileNewContents += "\n";
             else
               break;
           }
           else
           {
             FileNewContents += "\n" + NewValue;
             break;
           }
         }
         else
         {
           // ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' already has the KeyValue data '" + NewValue + "' on line '" + CurrentLine + "'.";
           // ::CM_PrintToHost( ::CM_DebugMessage );
           // throw ::CM_DebugMessage;
           FileNewContents = "";
           break;
         }
       }
       break;
     }

     case "List":
     {
       NewValueCount      = FileValue.len();
       NewValueTempCount  = NewValueCount;

       // Check if there's no KeyValue pairs to add
       if ( NewValueCount <= 0 )
       {
         ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The Array in Parameter 'FileValue' is empty.";
         ::CM_PrintToHost( ::CM_DebugMessage );
         throw ::CM_DebugMessage;
       }

       // Check if the file isn't empty.
       if ( strip( File ) != "" )
       {
         foreach ( Line in FileOldContents )
         {
           CurrentLine++;

           // Check if this line in FileOldContents contains the "|" delimiter.
           if ( Line.find( Delimiter2 ) != null )
           {
             /**
              * Check if is missing the 'Value' OR 'ValueType'
              */
             if ( split( Line, Delimiter2 ).len() != 2 )
             {
               ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
               ::CM_PrintToHost( ::CM_DebugMessage );
               throw ::CM_DebugMessage;
             }

             FileNewContents += Line + "\n";
           }
           else
           {
             ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
             ::CM_PrintToHost( ::CM_DebugMessage );
             throw ::CM_DebugMessage;
           }
         }
         CurrentLine = 0;
       }

       // Get and store the new value contents.
       foreach ( value in FileValue )
       {
         CurrentLine++;

         // Remove all white-space and/or "\n".
         FileNewContents = strip( FileNewContents );

         NewValueType  = ( typeof value );
         NewValue      = value + Delimiter2 + NewValueType;

         if ( FileNewContents.find( NewValue ) == null )
         {
           // Check if there's multiple KeyValue pairs.
           if ( NewValueCount >= 2 )
           {
             FileNewContents += "\n" + NewValue;

             NewValueTempCount--;

             // Check if there's more KeyValue pairs to add; then add "\n" if there's.
             if ( NewValueTempCount > 0 )
               FileNewContents += "\n";
             else
               break;
           }
           else
           {
             FileNewContents += "\n" + NewValue;
             break;
           }
         }
         else
         {
           // ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' already has the data '" + NewValue + "' on line '" + CurrentLine + "'.";
           // ::CM_PrintToHost( ::CM_DebugMessage );
           // throw ::CM_DebugMessage;
           FileNewContents = "";
           break;
         }
       }
       break;
     }

     case "CVar":
     {
       if ( strip( File ) == "" )
       {
         NewValueType    = ( typeof FileValue );
         NewValue        = FileValue + Delimiter2 + NewValueType;
         FileNewContents = NewValue;
       }
       else
       {
         // ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' already has one data on line '1'.";
         // ::CM_PrintToHost( ::CM_DebugMessage );
         // throw ::CM_DebugMessage;
         FileNewContents = "";
         break;
       }
       break;
     }
   }

   /**
    * Check if there are new contents to add.
    * If there are, return true; otherwise, will return false.
    */
   if ( FileNewContents != "" )
   {
     /**
      * If the file exists,
      * try to add his data and return true to indicate success.
      */
     local TryToAddConfigFile = StringToFile( FullPath, strip( FileNewContents ) );

     if ( TryToAddConfigFile )
        return true;
   }

   return false;
  }

  /**
   * If the file doesn't exist, return false and print a DebugMessage
   * to indicate that it couldn't be added.
   */
  ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' doesn't exist.";
  ::CM_PrintToHost( ::CM_DebugMessage );

  return false;
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Removes data into a Config File.
 *
 * @info      {any}     = {string|integer|float|bool|table|array}
 *
 * @param     {string}  FileFolder    - The Folder Name,  e.g. "cm_config_manager".
 * @param     {string}  FileName      - The File Name,    e.g. "config_manager_settings".
 * @param     {string}  FileType      - The File Type, either "KeyValue" or "List" or "CVar".
 * @param     {any}     FileValue     - The value to be removed from the file.
 *
 * @usages
 * Examples:
 * ::CM_ConfigManager.Remove( "cm_config_manager", "config_manager_configs", "KeyValue", { IsAdminOnly = true } );
 * ::CM_ConfigManager.Remove( "cm_config_manager", "config_manager_players", "List", [ "Player1", "PlayerOne" ] );
 * ::CM_ConfigManager.Remove( "cm_config_manager", "config_manager_enabled", "CVar", "" );
 *
 * @warning             If the parameter 'FileType' is 'CVar', leave the parameter "FileValue" as an empty string "".
 *
 * @throws    {string}  If any of the parameters are invalid or incompatible,
 *                      if the file doesn't exist, if the file is missing something and so on.
 *
 * @returns   {bool}    Returns true if the data was removed from the file successfully, or false if it couldn't.
 */
::CM_ConfigManager.Remove                   <- function( FileFolder, FileName, FileType, FileValue )
{
  local FullPath            = FileFolder + "/" + FileName + ".txt";
  local File                = FileToString( FullPath );
  local FileOldContents     = "";
  local FileNewContents     = "";
  local Delimiter           = "=";
  local Delimiter2          = "|";
  local FileValueType       = ( typeof FileValue );
  local CurrentLine         = 0;
  local FileValueCount      = 0;
  local Key                 = "";
  local Value               = "";
  local FunctionName        = "CM_ConfigManager.Remove()";

  // Check if FileFolder, FileName and FileType are valid non-empty strings.
  ::CM_ConfigManager.ValidateStringParameter( FileFolder, "FileFolder", FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileName,   "FileName",   FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileType,   "FileType",   FunctionName );

  // Check if FileValue is or not invalid.
  ::CM_ConfigManager.ValidateFileValueType( FileValueType, "FileValue", FunctionName );

  // Check if FileType is or not invalid.
  ::CM_ConfigManager.ValidateFileType( FileType, FileValueType, FunctionName );

  // Check if the file exist.
  if ( File != null )
  {
   switch ( FileType )
   {
     case "KeyValue":
     {
       FileValueCount = FileValue.len();

       // Check if there's no KeyValue pairs to remove.
       if ( FileValueCount <= 0 )
       {
         ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The Table in Parameter 'FileValue' is empty.";
         ::CM_PrintToHost( ::CM_DebugMessage );
         throw ::CM_DebugMessage;
       }

       // Check if the file isn't empty.
       if ( strip( File ) != "" )
       {
         FileOldContents = split( strip( File ), "\n" );

         foreach ( Line in FileOldContents )
         {
           CurrentLine++;

           // Check if this line in FileOldContents contains the "=" delimiter.
           if ( Line.find( Delimiter ) != null )
           {
             LineSplitEqual = split( Line, Delimiter );
             Key            = LineSplitEqual[0];

             // Check if this line in FileOldContents contains the "|" delimiter.
             if ( Line.find( Delimiter2 ) != null )
             {
               // Check if is missing the 'Value' OR 'ValueType'.
               if ( split( Line, Delimiter2 ).len() != 2 )
               {
                 ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
                 ::CM_PrintToHost( ::CM_DebugMessage );
                 throw ::CM_DebugMessage;
               }

               /**
                * If the Key isn't in the Table,
                * will be added into FileNewContents (removing the specified values in the Table)
                */
               if ( !( Key in FileValue )  )
               {
                 FileNewContents += Line + "\n";
               }
             }
             else
             {
               ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
               ::CM_PrintToHost( ::CM_DebugMessage );
               throw ::CM_DebugMessage;
             }
           }
           else
           {
             ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter + "' delimiter on line '" + CurrentLine + "'.";
             ::CM_PrintToHost( ::CM_DebugMessage );
             throw ::CM_DebugMessage;
           }
         }
         CurrentLine = 0;
       }
       break;
     }

     case "List":
     {
       FileValueCount = FileValue.len();

       // Check if there's no Values to remove.
       if ( FileValueCount <= 0 )
       {
         ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The Array in Parameter 'FileValue' is empty.";
         ::CM_PrintToHost( ::CM_DebugMessage );
         throw ::CM_DebugMessage;
       }

       // Check if the file isn't empty.
       if ( strip( File ) != "" )
       {
         FileOldContents = split( strip( File ), "\n" );

         foreach ( Line in FileOldContents )
         {
           CurrentLine++;

           local LineSplitSeparator = split( Line, Delimiter2 );

           // Check if this line in FileOldContents contains the "|" delimiter.
           if ( Line.find( Delimiter2 ) != null )
           {
             //Check if is missing the 'Value' OR 'ValueType'
             if ( LineSplitSeparator.len() != 2 )
             {
               ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
               ::CM_PrintToHost( ::CM_DebugMessage );
               throw ::CM_DebugMessage;
             }

             Value = LineSplitSeparator[0];

             /**
              * If the Value isn't in the Array,
              * will be added into FileNewContents (removing the specified values in the Array)
              */
             if ( FileValue.find( Value ) == null )
             {
               FileNewContents += Line + "\n";
             }
           }
           else
           {
             ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
             ::CM_PrintToHost( ::CM_DebugMessage );
             throw ::CM_DebugMessage;
           }
         }
         CurrentLine = 0;
       }
       break;
     }

     case "CVar":
     {
       break;
     }
   }

   /**
    * Check if there are new contents to remove.
    * If there are, return true; otherwise, will return false.
    */
   if ( FileNewContents != "" || FileType == "CVar" )
   {
     /**
      * If the file exists,
      * try to remove his data and return true to indicate success.
      */
     local TryToRemoveConfigFile = StringToFile( FullPath, strip( FileNewContents ) );

     if ( TryToRemoveConfigFile )
       return true;
   }

   return false;
  }

  /**
   * If the file doesn't exist, return false and print a DebugMessage
   * to indicate that it couldn't be removed.
   */
  ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' doesn't exist.";
  ::CM_PrintToHost( ::CM_DebugMessage );

  return false;
}

/**
 * @author    Sr.Caveira | 頭蓋骨 </> Dark'
 * @function  Gets data into a Config File.
 *
 * @param     {string}  FileFolder    - The Folder Name,  e.g. "cm_config_manager".
 * @param     {string}  FileName      - The File Name,    e.g. "config_manager_settings".
 * @param     {string}  FileType      - The File Type, either "KeyValue" or "List" or "CVar".
 * @param     {string}  FileValue     - The value to be get from the file.
 *
 * @usages
 * Examples:
 * ::CM_ConfigManager.Get( "cm_config_manager", "config_manager_configs", "KeyValue", "IsAdminOnly" );
 * ::CM_ConfigManager.Get( "cm_config_manager", "config_manager_players", "List", "Player1" );
 * ::CM_ConfigManager.Get( "cm_config_manager", "config_manager_enabled", "CVar", "" );
 *
 * @warning             If the parameter 'FileType' is 'CVar', leave the parameter "FileValue" as an empty string "".
 *
 * @throws    {string}  If any of the parameters are invalid or incompatible,
 *                      if the file doesn't exist, if the file is missing something and so on.
 *
 * @returns   {bool}    Returns a table if the data was get from the file successfully, or false if it couldn't.
 */
::CM_ConfigManager.Get                      <- function( FileFolder, FileName, FileType, FileValue )
{
  local FullPath            = FileFolder + "/" + FileName + ".txt";
  local File                = FileToString( FullPath );
  local FileContents        = File;
  local Delimiter           = "=";
  local Delimiter2          = "|";
  local FileValueType       = ( typeof FileValue );
  local CurrentLine         = 0;
  local Key                 = "";
  local Value               = {}; // KEYS: Key, Value, ValueType
  local LineSplitEqual      = "";
  local LineSplitSeparator  = "";
  local FunctionName        = "CM_ConfigManager.Get()";

  // Check if FileFolder, FileName, FileType and FileValue are valid non-empty strings.
  ::CM_ConfigManager.ValidateStringParameter( FileFolder, "FileFolder", FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileName,   "FileName",   FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileType,   "FileType",   FunctionName );
  ::CM_ConfigManager.ValidateStringParameter( FileValue,  "FileValue",  FunctionName );

  // Check if the file exist.
  if ( File != null )
  {
   switch ( FileType )
   {
     case "KeyValue":
     {
      // Check if the file isn't empty.
      if ( strip( File ) != "" )
      {
        FileContents = split( strip( File ), "\n" );

        foreach ( Line in FileContents )
        {
          CurrentLine++;

          // Check if this line in FileContents contains the "=" delimiter.
          if ( Line.find( Delimiter ) != null )
          {
            LineSplitEqual  = split( Line, Delimiter );
            Key             = LineSplitEqual[0];

            // Check if this line in FileContents contains the "|" delimiter.
            if ( Line.find( Delimiter2 ) != null )
            {
              LineSplitSeparator = split( Line, Delimiter2 );

              // Check if is missing the 'Value' OR 'ValueType'.
              if ( split( Line, Delimiter2 ).len() != 2 )
              {
                ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
                ::CM_PrintToHost( ::CM_DebugMessage );
                throw ::CM_DebugMessage;
              }

              if ( Key == FileValue )
              {
                Value.Key       <- Key;
                Value.Value     <- split( LineSplitSeparator[0], Delimiter )[1];
                Value.ValueType <- LineSplitSeparator[1];
                Value.Value     <- ::CM_ConvertValueType( Value.Value, Value.ValueType );
                break;
              }
            }
            else
            {
              ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
              ::CM_PrintToHost( ::CM_DebugMessage );
              throw ::CM_DebugMessage;
            }
          }
          else
          {
            ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter + "' delimiter on line '" + CurrentLine + "'.";
            ::CM_PrintToHost( ::CM_DebugMessage );
            throw ::CM_DebugMessage;
          }
        }
      }
      else
      {
        Value.Key       <- "";
        Value.Value     <- "";
        Value.ValueType <- "string";
      }
      break;
     }

     case "List":
     {
      // Check if the file isn't empty.
      if ( strip( File ) != "" )
      {
        FileContents = split( strip( File ), "\n" );

        foreach ( Line in FileContents )
        {
          CurrentLine++;

          // Check if this line in FileContents contains the "|" delimiter.
          if ( Line.find( Delimiter2 ) != null )
          {
            LineSplitSeparator = split( Line, Delimiter2 );

            // Check if is missing the 'Value' OR 'ValueType'.
            if ( split( Line, Delimiter2 ).len() != 2 )
            {
              ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '" + CurrentLine + "'.";
              ::CM_PrintToHost( ::CM_DebugMessage );
              throw ::CM_DebugMessage;
            }

            if ( LineSplitSeparator[0] == FileValue )
            {
              Value.Value     <- LineSplitSeparator[0];
              Value.ValueType <- LineSplitSeparator[1];
              Value.Value     <- ::CM_ConvertValueType( Value.Value, Value.ValueType );
              break;
            }
          }
          else
          {
            ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing the '" + Delimiter2 + "' delimiter on line '" + CurrentLine + "'.";
            ::CM_PrintToHost( ::CM_DebugMessage );
            throw ::CM_DebugMessage;
          }
        }
      }
      else
      {
        Value.Key       <- "";
        Value.Value     <- "";
        Value.ValueType <- "string";
      }
      break;
     }

     case "CVar":
     {
      // Check if the file isn't empty.
      if ( strip( File ) != "" )
      {
        // Check if this line in FileContents contains the "|" delimiter.
        if ( FileContents.find( Delimiter2 ) != null )
        {
          LineSplitSeparator = split( FileContents, Delimiter2 );

          // Check if is missing the 'Value' OR 'ValueType'.
          if ( split( FileContents, Delimiter2 ).len() != 2 )
          {
            ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' is missing 'Value' OR 'ValueType' on line '1'.";
            ::CM_PrintToHost( ::CM_DebugMessage );
            throw ::CM_DebugMessage;
          }

          Value.Value     <- LineSplitSeparator[0];
          Value.ValueType <- LineSplitSeparator[1];
          Value.Value     <- ::CM_ConvertValueType( Value.Value, Value.ValueType );

          break;
        }
      }
      else
      {
        Value.Key       <- "";
        Value.Value     <- "";
        Value.ValueType <- "string";
      }
      break;
     }
   }

   /**
    * Check if there are values to get.
    * If there are, return an Table with the values; otherwise, will return false.
    */
   if ( Value.len() != 0 )
   {
     /**
      * If the file exists,
      * try to get his data and return an Table with the values to indicate success.
      */
     return Value;
   }

   return false;
  }

  /**
   * If the file doesn't exist, return false and print a DebugMessage
   * to indicate that it couldn't be get.
   */
  ::CM_DebugMessage <- "[Config Manager] " + FunctionName + " : The file '" + FullPath + "' doesn't exist.";
  ::CM_PrintToHost( ::CM_DebugMessage );

  return false;
}