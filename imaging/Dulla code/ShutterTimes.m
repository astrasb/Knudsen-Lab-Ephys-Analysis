function [ShutterOpenValues, ShutterCloseValues] = ShutterTimes(Ch1ROI, Ch2ROI, ExposureNumber, FrameTimes, AdjustedTime);

shuttertest=0;
ShutterValues=zeros(2*ExposureNumber);  
for exposure=1:ExposureNumber
    timetest=FrameTimes(1,exposure);
    shuttertest=shuttertest+1;
    if timetest>0
        x=Ch1ROI(:,exposure);
        t=AdjustedTime(:,exposure);
        dx=diff(x);
        dt=diff(t);
        deriv=dx./dt;
        dderiv=deriv./dt;
        dMax=max(dderiv);
        dMin=min(dderiv);
        tMax=find(dderiv==dMax);
        tMin=find(dderiv==dMin);
        ShutterOpen=tMax+1;
        ShutterClose=tMin-1;
    else
       ShutterOpen=0;
       ShutterClose=0;
    end
   if shuttertest==1
      ShutterOpenValues=ShutterOpen;
      ShutterCloseValues=ShutterClose;
   else
      ShutterOpenValues=[ShutterOpenValues; ShutterOpen];
      ShutterCloseValues=[ShutterCloseValues; ShutterClose];
 
   end
end
end