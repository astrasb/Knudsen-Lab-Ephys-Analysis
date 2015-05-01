function [Image,InstaImage,CalibImage,vers,PathName,FileName]=andorread_chris_local()
  % f is filename
  [FileName,PathName,FilterIndex] = uigetfile('/mnt/m022a/2009_03_20/')
  fname=sprintf('%s%s',PathName,FileName);
  f=fopen(fname);
  title=read_string(f,'\n');
  if ~strcmp('Andor Technology Multi-Channel File',title)
%      ~= 0) &&
%  if ((strcmp('Andor Technology Multi-Channel File',title) ~= 0) &&
 %    ( strcmp('Oriel Instruments Multi-Channel File',title) ~= 0) )

  	display('This is not a proper SIF file: The file may be corrupt');
    andordata=0;
    return ;
  end
  display(title);
  vers = read_int(f,' '); %//Version
  msg=sprintf('Version: %d.%d',HIWORD(vers),LOWORD(vers));
  display(msg);
  for p=0:4
  	if(~feof(f))
  		is_present = read_int(f,'\n');
  		msg=sprintf('int: is_present: %d:',is_present);
        display(msg);
    	%// Following section only is repeated number_of_images times.
  		if (is_present==1)
            [InstaImage,vers]=read_instaimage(f);
            [CalibImage]=read_calibimage(f);
  			[Image]=read_image_structure(f);
        end 		%}//End if(is_present =1)
    end %}//if(!feof(in))
  end %}//End for(p=0;p<4;p++)
  fscanf(f,'%c',1);
  if(feof(f)) 
      display('File has now been successfully read');
  else display('End of file has not been reached');
  end
  fclose(f);
end

function intval=read_int(f,t)
int_str=read_string(f,t);
if ~isempty(int_str)
intval=sscanf(int_str,'%d');
else
    intval=-1;
end
end

function floatval=read_float(f,t)
float_str=read_string(f,t);
floatval=sscanf(float_str,'%f');
end

function strval=read_string(f,t)
ch=0;
i=1;
if strcmp(t,'\n')
    t=char(10); %newline character
end
while ch ~= t
ch=fscanf(f,'%c',1);
%uint8(ch)
if ch ~= t
ch_ar(i)=ch;
i=i+1;
end
end
if (i>1)
strval=char(ch_ar);
else
    strval='';
end
end

function byteval=read_byte_and_skip_terminator(f)
ch=fscanf(f,'%c',1);
fscanf(f,'%c',1); %discard terminator
strval=char(ch);
byteval=sscanf(strval,'%d');
end

function charval=read_char_and_skip_terminator(f)
ch=fscanf(f,'%c',1);
fscanf(f,'%c',1); %discard terminator
charval=char(ch);
end

function charval=read_char(f)
ch=fscanf(f,'%c',1);
charval=char(ch);
end

function strval=read_len_chars(f,n)
for i=1:n
    ch(i)=read_char(f);
end
if n>0
strval=char(ch);
else
    strval='';
end
end

function word=HIWORD(intval)
word=bitand(bitshift(intval,-16),65535);
end

function word=LOWORD(intval)
word=bitand(intval,65535);
end


function [InstaImage,vers]=read_instaimage(f)
  vers(1) = read_int(f,' '); 
  InstaImage.type = read_int(f,' ');
  InstaImage.active = read_int(f,' ');
  InstaImage.structure_vers = read_int(f,' ');
  InstaImage.timedate = read_int(f,' ');
  InstaImage.temperature = read_float(f,' ');
  InstaImage.head = read_byte_and_skip_terminator(f);
  InstaImage.store_type = read_byte_and_skip_terminator(f);
  InstaImage.data_type = read_byte_and_skip_terminator(f);
  InstaImage.mode = read_byte_and_skip_terminator(f);
  InstaImage.trigger_source = read_byte_and_skip_terminator(f);
  InstaImage.trigger_level = read_float(f,' ');
  InstaImage.exposure_time = read_float(f,' ');
  InstaImage.delay = read_float(f,' ');
  InstaImage.integration_cycle_time = read_float(f,' ');
  InstaImage.no_integrations = read_int(f,' ');
  InstaImage.sync = read_byte_and_skip_terminator(f);
  InstaImage.kinetic_cycle_time = read_float(f,' ');
  InstaImage.pixel_readout_time = read_float(f,' ');
  InstaImage.no_points = read_int(f,' ');
  InstaImage.fast_track_height = read_int(f,' ');
	InstaImage.gain = read_int(f,' ');
  InstaImage.gate_delay = read_float(f,' ');
  InstaImage.gate_width = read_float(f,' ');

  if( (HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=6) )
    InstaImage.GateStep = read_float(f,' ');
  end
  InstaImage.track_height = read_int(f,' ');
  InstaImage.series_length = read_int(f,' ');
  InstaImage.read_pattern = read_byte_and_skip_terminator(f);
  InstaImage.shutter_delay = read_byte_and_skip_terminator(f);

  if( (HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=7) ) 
    InstaImage.st_centre_row = read_int(f,' ');
    InstaImage.mt_offset = read_int(f,' ');
    InstaImage.operation_mode = read_int(f,' ');
  end

  if( (HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=8) ) 
    InstaImage.FlipX = read_int(f,' ');
    InstaImage.FlipY = read_int(f,' ');
    InstaImage.Clock = read_int(f,' ');
    InstaImage.AClock = read_int(f,' ');
    InstaImage.MCP = read_int(f,' ');
    InstaImage.Prop = read_int(f,' ');
    InstaImage.IOC = read_int(f,' ');
    InstaImage.Freq = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=9)) 
    InstaImage.VertClockAmp = read_int(f,' ');
    InstaImage.data_v_shift_speed = read_float(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=10)) 
    InstaImage.OutputAmp = read_int(f,' ');
    InstaImage.PreAmpGain = read_float(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=11)) 
    InstaImage.Serial = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=13)) 
    InstaImage.NumPulses = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=14)) 
    InstaImage.mFrameTransferAcqMode = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=15)) 
    InstaImage.unstabilizedTemperature = read_float(f,' ');
    InstaImage.mBaselineClamp = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=16))
    InstaImage.mPreScan = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=17))
    InstaImage.mEMRealGain = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=18))
    InstaImage.mBaselineOffset = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=19))
    InstaImage.mSWvers = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=20))
    InstaImage.miGateMode = read_int(f,' ');
  end

  if((HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=21)) 
    InstaImage.mSWDllVer = read_int(f,' ');
    InstaImage.mSWDllRev = read_int(f,' ');
    InstaImage.mSWDllRel = read_int(f,' ');
    InstaImage.mSWDllBld = read_int(f,' ');
  end

  if( (HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=5) )
    read_int(f,'\n');%//
    InstaImage.head_model=read_string(f,'\n');
    InstaImage.detector_format_x = read_int(f,' ');
    InstaImage.detector_format_z = read_int(f,' ');
  elseif( (HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=3) )
    head_model = read_int(f,' ');
    sprintf(InstaImage.head_model,'%d',head_model);
    InstaImage.detector_format_x = read_int(f,' ');
    InstaImage.detector_format_z = read_int(f,' ');
  else 
	 strcpy(InstaImage.head_model,'Unknown');
	 InstaImage.detector_format_x = 1024;
	 InstaImage.detector_format_z = 256;
  end

  read_int(f,'\n');
  InstaImage.filename=read_string(f,'\n');

  %//Start of TUserText
  vers(2) = read_int(f,' ');
  result=read_int(f,'\n');
  InstaImage.user_text.text=read_len_chars(f,result);
  %//End of TUserText

  %//Start of TShutter
  if( (HIWORD(vers(1)) >= 1) && (LOWORD(vers(1)) >=4) ) 
    vers(3) = read_int(f,' ');
    InstaImage.shutter.type = read_char_and_skip_terminator(f);
    InstaImage.shutter.mode = read_char_and_skip_terminator(f);
    InstaImage.shutter.custom_bg_mode = read_char_and_skip_terminator(f);
    InstaImage.shutter.custom_mode = read_char_and_skip_terminator(f);
    InstaImage.shutter.closing_time = read_float(f,' ');
    InstaImage.shutter.opening_time = read_float(f,'\n');
  end
  %// End of TShutter

  %//Start of TShamrockSave
  if( (HIWORD(vers(1))>1) || ((HIWORD(vers(1))==1) && (LOWORD(vers(1)) >=12)) )
    vers(4) = read_int(f,' ');
    InstaImage.shamrock_save.IsActive = read_int(f,' ');
  	InstaImage.shamrock_save.WavePresent = read_int(f,' ');
  	InstaImage.shamrock_save.Wave = read_float(f,' ');
    InstaImage.shamrock_save.GratPresent = read_int(f,' ');
    InstaImage.shamrock_save.GratIndex = read_int(f,' ');
    InstaImage.shamrock_save.GratLines = read_float(f,' ');
    InstaImage.shamrock_save.GratBlaze=read_string(f,'\n');
    InstaImage.shamrock_save.SlitPresent = read_int(f,' ');
    InstaImage.shamrock_save.SlitWidth = read_float(f,' ');
    InstaImage.shamrock_save.FlipperPresent = read_int(f,' ');
    InstaImage.shamrock_save.FlipperPort = read_int(f,' ');
    InstaImage.shamrock_save.FilterPresent = read_int(f,' ');
    InstaImage.shamrock_save.FilterIndex = read_int(f,' ');
    len = read_int(f,' ');
    InstaImage.shamrock_save.FilterString=read_len_chars(f,len);
    InstaImage.shamrock_save.AccessoryPresent = read_int(f,' ');
    InstaImage.shamrock_save.Port1State = read_int(f,' ');
    InstaImage.shamrock_save.Port2State = read_int(f,' ');
    InstaImage.shamrock_save.Port3State = read_int(f,' ');
    InstaImage.shamrock_save.Port4State = read_int(f,' ');
    InstaImage.shamrock_save.OutputSlitPresent = read_int(f,' ');
    InstaImage.shamrock_save.OutputSlitWidth = read_float(f,' ');

    if (LOWORD(vers(4)) >= 1 || HIWORD(vers(4)) > 1) 
      InstaImage.shamrock_save.IsStepAndGlue = read_int(f,' ');
    end

    if (LOWORD(vers(4)) >= 2 || HIWORD(vers(4)) > 1) 
      InstaImage.shamrock_save.SpectrographName=read_string(f,'\n');
    end
  end
  %//End of TShamrockSave


  %//Start of TSpectrographSave
  if( (HIWORD(vers(1))>1) || ((HIWORD(vers(1))==1) && (LOWORD(vers(1)) >=22)) )
    vers(5) = read_int(f,' ');
    InstaImage.spec_save.IsActive = read_int(f,' ');
  	InstaImage.spec_save.Wave = read_float(f,' ');
    InstaImage.spec_save.GratLines = read_float(f,' ');
    InstaImage.spec_save.SpectrographName=read_string(f,'\n');
  end
  %//End of TSpectrographSave

end%// End of read_instaimage

function [CalibImage]=read_calibimage(f)
  vers = read_int(f,' ');
  CalibImage.x_type = read_byte_and_skip_terminator(f);
  CalibImage.x_unit = read_byte_and_skip_terminator(f);
  CalibImage.y_type = read_byte_and_skip_terminator(f);
  CalibImage.y_unit = read_byte_and_skip_terminator(f);
  CalibImage.z_type = read_byte_and_skip_terminator(f);
  CalibImage.z_unit = read_byte_and_skip_terminator(f);
  CalibImage.x_cal(1) = read_float(f,' ');
  CalibImage.x_cal(2) = read_float(f,' ');
  CalibImage.x_cal(3) = read_float(f,' ');
  CalibImage.x_cal(4) = read_float(f,'\n');
  CalibImage.y_cal(1) = read_float(f,' ');
  CalibImage.y_cal(2) = read_float(f,' ');
  CalibImage.y_cal(3) = read_float(f,' ');
  CalibImage.y_cal(4) = read_float(f,'\n');
  CalibImage.z_cal(1) = read_float(f,' ');
  CalibImage.z_cal(2) = read_float(f,' ');
  CalibImage.z_cal(3) = read_float(f,' ');
  CalibImage.z_cal(4) = read_float(f,'\n');

  if ( (HIWORD(vers) >= 1) && (LOWORD(vers) >=3) )
    CalibImage.rayleigh_wavelength = read_float(f,'\n');
    CalibImage.pixel_length = read_float(f,'\n');
    CalibImage.pixel_height = read_float(f,'\n');
  end

  len = read_int(f,'\n');
  CalibImage.x_text=read_len_chars(f,len);
  len = read_int(f,'\n');
  CalibImage.y_text=read_len_chars(f,len);
  len = read_int(f,'\n');
  CalibImage.z_text=read_len_chars(f,len);
  end
 %//End of TCalibImage

 function [Image]= read_image_structure(f)
  vers = read_int(f,' ');
  Image.image_format.left = read_int(f,' ');
  Image.image_format.top = read_int(f,' ');
  Image.image_format.right = read_int(f,' ');
  Image.image_format.bottom = read_int(f,' ');
  Image.no_images = read_int(f,' ');
  Image.no_subimages = read_int(f,' ');
  Image.total_length = read_int(f,' ');
  Image.image_length = read_int(f,'\n');
%  version2 = (long*)malloc((sizeof(long))*Image.no_subimages);
%  if (!version2) printf("Cannot create version2 buffer array ");
%  Image.position = malloc((sizeof)*Image.no_subimages*6);
%  if (!Image.position) printf("Cannot create Image.position buffer array ");
%  Image.subimage_offset = malloc((sizeof(unsigned long))*Image.no_subimages);
%  if (!Image.subimage_offset) printf("Cannot create Image.subimage_offset buffer array ");
  for j=1:Image.no_subimages % //Repeat no_subimages times
  	version2(j) = read_int(f,' ');
    Image.position(j).left= read_int(f,' ');
    Image.position(j).top = read_int(f,' ');
    Image.position(j).right = read_int(f,' ');
    Image.position(j).bottom = read_int(f,' ');
    Image.position(j).vertical_bin = read_int(f,' ');
    Image.position(j).horizontal_bin = read_int(f,' ');
    Image.subimage_offset(j) = read_int(f,'\n');
  end %} // End of for(j=0;j<no_subimages;j++)


%  Image.time_stamps = malloc((sizeof(unsigned long))*Image.no_images);
  for k=1:Image.no_images
  	Image.time_stamps(k) = read_int(f,'\n');
  end
%s=(1 + diff(info.frameArea))./info.frameBins;
%z=1 + diff(info.imageArea(5:6));
%Image.data=reshape(fread(f,prod(s)*z,'single=>single'),[s z]);
width=(Image.position(1).top-Image.position(1).bottom+1)/Image.position.horizontal_bin;
height=(Image.position(1).right-Image.position(1).left+1)/Image.position.vertical_bin;

    Image.data=reshape(fread(f,Image.total_length,'single=>single'),[ width height Image.no_images]);
%  read_image(Image.total_length,image_buff);
  end % }//read_image_structure;
