%Read Andor SIF multi-channel image file.
%
%Synopsis:
%
%  [data,back,ref]=sifread(file)
%     Read the image data, background and reference from file.
%     Return the image data, background and reference in named
%     structures as follows:
%
%  .temperature            CCD temperature [�C]
%   .unixtimestamp            Number of seconds since Jan 1, 1970
% .timestring              string containing file creation date and time
%  .exposureTime           Exposure time [s]
%  .cycleTime              Time per full image take [s]
%  .accumulateCycles       Number of accumulation cycles
%  .accumulateCycleTime    Time per accumulated image [s]
%  .stackCycleTime         Interval in image series [s]
%  .pixelReadoutTime       Time per pixel readout [s]
%  .detectorType           CCD type
%  .detectorSize           Number of read CCD pixels [x,y]
%  .fileName               Original file name
%  .shutterTime            Time to open/close the shutter [s]
%  .frameAxis              Axis unit of CCD frame
%  .dataType               Type of image data
%  .imageAxis              Axis unit of image
%  .imageArea              Image limits [x1,y1,first image;
%                                        x2,y2,last image]
%  .frameArea              Frame limits [x1,y1;x2,y2]
%  .frameBins              Binned pixels [x,y]
%  .timeStamp              Time stamp in image series
%  .imageData              Image data (x,y,t)

%Note:
%
%  The file format was reverse engineered by identifying known
%  information within the corresponding file. There are still
%  non-identified regions left over but the current summary is
%  available on request.
%

%        Marcel Leutenegger � November 2006
%
function [data,back,ref]=sifread(file)
f=fopen(file,'r');
if f < 0
   error('Could not open the file.');
end
if ~isequal(fgetl(f),'Andor Technology Multi-Channel File')
   fclose(f);
   error('Not an Andor SIF image file.');
end
skipLines(f,1);
[data,next]=readSection(f);
if nargout > 1 & next == 1
   [back,next]=readSection(f);
   if nargout > 2 & next == 1
      ref=back;
      back=readSection(f);
   else
      ref=struct([]);
   end
else
   back=struct([]);
   ref=back;
end
fclose(f);


%Read a file section.
%
% f      File handle
% info   Section data
% next   Flags if another section is available
%
function [info,next]=readSection(f)
o=fscanf(f,'%d',6);
info.unixtimestamp=o(5);
info.timestring=datestr(unix2matlabtimestamp(o(5)));
info.temperature=o(6);
skipBytes(f,10);
o=fscanf(f,'%f',5);
info.exposureTime=o(2);
info.cycleTime=o(3);
info.accumulateCycles=o(5);
info.accumulateCycleTime=o(4);
skipBytes(f,2);
o=fscanf(f,'%f',2);
info.stackCycleTime=o(1);
info.pixelReadoutTime=o(2);
o=fscanf(f,'%d',3);
info.gainDAC=o(3);
skipLines(f,1);
info.detectorType=readLine(f); % needs to be checked according to matlab central http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=11224
info.detectorSize=fscanf(f,'%d',[1 2]);
info.fileName=readString(f);
skipLines(f,3);
skipBytes(f,14);
info.shutterTime=fscanf(f,'%f',[1 2]); % Broken Shutter - ERROR POINT>>>??????????????????
skipLines(f,8);
%if (length(strmatch('Luc',info.detectorType))  || strcmp('DV897_BV',info.detectorType) || strcmp('DU860_BV',info.detectorType)) %% needs to be changed according to matlab central 
%    skipLines(f,2);                       % Andor Luca
%end
siftype=1;  % 2=old Solis softwar 1=new software
if siftype==1
fseek(f,1014,'bof');                     % Andor Luca
info.frameAxis=fread(f,12,'uint8=>char')';
fseek(f,1028,'bof');
info.dataType=fread(f,6,'uint8=>char')';
fseek(f,1037,'bof');
info.imageAxis=fread(f,12,'uint8=>char')';


else
skipLines(f,2);                       % Andor Luca
info.frameAxis=readString(f);
info.dataType=readString(f);
info.imageAxis=readString(f);
    
end
o=fscanf(f,'65538 %d %d %d %d %d %d %d %d 65538 %d %d %d %d %d %d',14);
info.imageTotalLength=[o(7)];
info.imageArea=[o(1) o(4) o(6);o(3) o(2) o(5)];
info.frameArea=[o(9) o(12);o(11) o(10)];
info.frameBins=[o(14) o(13)];
s=(1 + diff(info.frameArea))./info.frameBins;
z=1 + diff(info.imageArea(5:6));
if prod(s) ~= o(8) | o(8)*z ~= o(7)
   fclose(f);
   error('Inconsistent image header.');
end
for n=1:z
   o=readString(f);
   if numel(o)
      fprintf('%s\n',o);      % comments
   end

info.timeStamp(n)=fread(f,1,'uint16');
end
skipBytes(f,9);
info.imageData=reshape(fread(f,prod(s)*z,'single=>single'),[s z]);
%info.imageData=reshape(fread(f,info.imageTotalLength,'char=>single'),[s z]);
if siftype==2
o=readString(f);           % ???
if numel(o)
   fprintf('%s\n',o);      % ???
end
end
next=fscanf(f,'%d',1);


%Read a character string.
%
% f      File handle
% o      String
%
function o=readString(f)
n=fscanf(f,'%d',1);
if isempty(n) | n < 0 | isequal(fgetl(f),-1)
   fclose(f);
   error('Inconsistent string.');
end
o=fread(f,[1 n],'uint8=>char');


%Read a line.
%
% f      File handle
% o      Read line
%
function o=readLine(f)
o=fgetl(f);
if isequal(o,-1)
   fclose(f);
   error('Inconsistent image header.');
end
o=deblank(o);


%Skip bytes.
%
% f      File handle
% N      Number of bytes to skip
%
function skipBytes(f,N)
[s,n]=fread(f,N,'uint8');
if n < N
   fclose(f);
   error('Inconsistent image header.');
end


%Skip lines.
%
% f      File handle
% N      Number of lines to skip
%
function skipLines(f,N)
for n=1:N
   if isequal(fgetl(f),-1)
      fclose(f);
      error('Inconsistent image header.');
   end
end

function readint(f)

