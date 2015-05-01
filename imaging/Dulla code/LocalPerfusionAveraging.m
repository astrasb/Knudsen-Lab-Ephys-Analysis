%%%% Image Averaging for creating averaged single images of FLs



Happiness=questdlg('Please Select your first local perfusion experiment to average','GOULET INC');
[Image,InstaImage,CalibImage,vers,PathName,FileName]=andorread_chris_local()
temp=Image.data;

