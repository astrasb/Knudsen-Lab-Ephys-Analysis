function [subsampled_data, image_locations,Sweeps_with_images]=Andor_Frame_Capture_Detection_2(PClampData)


number_of_images=0;
for i=1:size(PClampData,3)
    if max(PClampData(:,2,i)>2)
        frame_numbertest=diff(squeeze(PClampData(:,2,i)));
        frame_numbertest_2=find(frame_numbertest>0.3);
        if (size(frame_numbertest_2,1)>5)&(size(frame_numbertest_2,1)<900)
            time_of_image_capture=0; 
            number_of_images=number_of_images+1;
            Sweeps_with_images(number_of_images)=i;
            jump = 10;
            Cont = 1;
            t = 1;
           
            while(Cont)
                if (frame_numbertest(t,1) > 0.1)
                    time_of_image_capture=time_of_image_capture+1;
                    image_locations(number_of_images,time_of_image_capture)=t;
                    subsampled_data(number_of_images,time_of_image_capture)=PClampData(t,1,i);
                    if ( t < length(frame_numbertest) - jump)
                        t = t+ jump -1;
                    end
                end
                t = t+1;
                if (t >= length(frame_numbertest))
                    Cont = 0;
                end
               
            end
            ok=1;
        end
    end
end
end