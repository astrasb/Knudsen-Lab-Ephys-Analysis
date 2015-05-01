
function [masterdata,directoryname, dd, ScaleFactor, OffsetFactor,andorscaled, cookscaled, txmatrix ]=andortest();
path = uigetdir('/mnt/m022a'); 
ext='sif';
path1=sprintf('%s/*.%s',path,ext);
disp(path);
d = dir (path1);
numfiles=length(d);
directoryname=path;
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
  t = length(getfield(d,{i},'name')) ;
  dd(i, 1:t) = getfield(d,{i},'name') ;
end
for thisfile = 1:numfiles
 %try/mnt/m022a
    
  fna=dd(thisfile,:);
 
  fna=strtok(fna,'.');
  %fna=fna(1:length(fna)-4);
disp(fna);
%fna='eeg3';
fn= sprintf('%s/%s.%s',path,fna,ext);
k=strfind(fna,'bright');

k=0;  % Turns off Registration
 if k==1
    ScaleFactor=10;
    OffsetFactor=-90;
    Happiness='No';
       while (strcmp(Happiness,'No')==1)
            [OutImage, andorscaled, cookscaled, txmatrix]=registration_test(fn,path, ScaleFactor, OffsetFactor) ;
            Happiness=questdlg('Are you happy with the alignment','Registration Checkpoint');
            if (strcmp(Happiness,'No')==1)
                prompt = {'Enter Scale Factor                 ','Enter Offset Factor                  '};
                dlg_title = 'Adjust Registration              ';
                num_lines = 1;
                def = {num2str(ScaleFactor),num2str(OffsetFactor)};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                ScaleFactor=str2num(answer{1,1});
                OffsetFactor=str2num(answer{2,1});
            end
        end    
    
 else
[Image(thisfile-1),InstaImage,CalibImage,vers]=andorread(fn)
%[tempimages(thisfile),back,ref]=sifread(fn);
timestamps(thisfile-1)=InstaImage.timedate;
 end
%    catch
  % this matches the try for this particular file
  % will end up in this catch loop if there was an error during processing the file
 % disp('error in file');
  %errmsg=lasterr;
  %disp(errmsg);
  %end

end

[srt,imageorder]=sort(timestamps,2);
masterdata.imagetimestamps=timestamps;
masterdata.numimagesequences=size(timestamps,2);
for i=1:masterdata.numimagesequences
    masterdata.images(i)=Image(imageorder(i));
end
clear tempimages;
clear timestamps;
ext='abf';
path1=sprintf('%s/*.%s',path,ext);

d = dir (path1);
numfiles=length(d);
if numfiles<1
    disp('No files found');
end

for i = 1:numfiles
 t = length(getfield(d,{i},'name')) ;
 de(i, 1:t) = getfield(d,{i},'name') ;
end
for thisfile = 1:numfiles
  try
    
  fna=de(thisfile,:);
  fna=strtok(fna,'.');
  %fna=fna(1:length(fna)-4);
disp(fna);
%fna='eeg3';
fn= sprintf('%s/%s.%s',path,fna,ext);
[d,si,sw,tags,et,cn,timestamp]=abfload(fn);
timestamps(thisfile)=timestamp;
numsweeps=0;
for i=1:size(d,3)
imaging(i)= max(diff(d(:,2,i)));
% this codes finds camera busy signals and creates subsampled pclamp data
% traces based on the timing of these signals
if imaging(i)>1
    numsweeps=numsweeps+1;
    sweeptime(numsweeps)=et(i);
    sweepskept(numsweeps)=i;
    framesample=find(diff(d(:,2,i))>4);
    sampleswithimages{numsweeps}=framesample;
    newsample=1;
    for j=1:size(framesample)
        newsweep(newsample,numsweeps)=d(framesample(j),1,i);
        newsample=newsample+1;
    end
end
end
masterdata.pclamp(thisfile).sampleswithimages=sampleswithimages;
masterdata.pclamp(thisfile).filename=fna;
masterdata.pclamp(thisfile).data=newsweep;
masterdata.pclamp(thisfile).sweeptimes=sweeptime;
masterdata.pclamp(thisfile).origsweeptimes=et;
masterdata.pclamp(thisfile).sweeps=sweepskept;
masterdata.pclamp(thisfile).tags=tags;
masterdata.pclamp(thisfile).channelname=cn(1);
masterdata.pclamp(thisfile).si=si;
masterdata.pclamp(thisfile).origsweeps=sw;
masterdata.pclamp(thisfile).timestamp=timestamp;
masterdata.pclamp(thisfile).timestring=datestr(unix2matlabtimestamp(timestamp));
masterdata.pclamp(thisfile).origdata=d;
%datestr(unix2matlabtimestamp(timestamp))

    catch
  % this matches the try for this particular file
  % will end up in this catch loop if there was an error during processing the file
  disp('error in file');
  errmsg=lasterr;
  disp(errmsg);
  end

end

[srt,masterdata.axonorder]=sort(timestamps,2);
masterdata.axontimestamps=timestamps;

masterdata.numaxonfiles=size(timestamps,2);
% find the first and last camera busy signals in each trace
for i=1:masterdata.numaxonfiles
    clear firstsamples;
    clear lastsamples;
    for j=1:size(masterdata.pclamp(i).sweeps) %added size
        firstsamples(j)=min(masterdata.pclamp(i).sampleswithimages{j});
        lastsamples(j)=max(masterdata.pclamp(i).sampleswithimages{j});
    end
    % after finding first and last, then assume you can use the most common
    % value (from median filter) to apply to all image files
    % this assumes all will start and end with the same sample numbers
    masterdata.pclamp(i).firstimagesample=median(firstsamples);
    masterdata.pclamp(i).lastimagesample=median(lastsamples);
end
computertimediff=60*60*4+25;
%4 hours and 25 seconds difference between andor and pclamp data files
% on 11-apr-20008
% use the following code to find the corresponding pclamp traces
% and image sequences
for i=1:masterdata.numimagesequences
    ts=masterdata.imagetimestamps(i)-computertimediff;
    difftime=1e8;
    axonfilenum=0;
    axonswpnum=0;
    for j=1:masterdata.numaxonfiles
        for k=1:masterdata.pclamp(j).origsweeps
            thissweep=masterdata.pclamp(j).timestamp+masterdata.pclamp(j).origsweeptimes(k);
            thisdifftime=thissweep-ts;
            if (abs(thisdifftime)<difftime);
                difftime=abs(thisdifftime);
                axonfilenum=j;
                axonswpnum=k;
            end
        end
        masterdata.matchedswpnum(i)=axonswpnum;
    end
    masterdata.matcheddatafile(i)=axonfilenum;
end

    samplediff=masterdata.pclamp(axonfilenum).lastimagesample-masterdata.pclamp(axonfilenum).firstimagesample;
    %number of samples during imaging, as detected by camera ready signal
framespermovie=size(masterdata.images(1).data,3);  
masterdata.framespermovie=framespermovie;
    deltasample=samplediff/(framespermovie-1); % pclamp samples per image samples
    % number of pclamp samples per image sample
for i=1:masterdata.numimagesequences
    swp=masterdata.matchedswpnum(i);
    fl=masterdata.matcheddatafile(i);
    for j=1:framespermovie
        smple=int32(masterdata.pclamp(fl).firstimagesample+(j-1)*deltasample);
        masterdata.subsampleddata(i,j)=masterdata.pclamp(fl).origdata(smple,1,swp);
        %timetemp=masterdata.pclamp.sampleswithimages(fl);
        %timetempa=timetemp{1};
        %masterdata.subsampleddatatimes(i,j)=timetempa(j,1);
        %masterdata.subsampleddatatimes(i,j)=masterdata.pclamp.sampleswithimages(fl).(1,smple);
    end
end    
masterdata.imagetimes=[1:framespermovie]*si/1e3*deltasample;
matlabfile=sprintf('%s%s.mat',path,fna);
%save(matlabfile,'masterdata');
end
