function[FFTStructure]=FFT_StructureGenerator(Data,Time,FrameInterval)
FFTStructure.Data=double(Data);
FFTStructure.Time=double(Time);
FFTStructure.FS=1000/FrameInterval;
FFTStructure.SignalLabel='RatioData';
FFTStructure.SPTIdentifier.Type='Signal';
FFTStructure.SPTIdentifier.Version='1.0';
FFTStructure.type='Array';



end
