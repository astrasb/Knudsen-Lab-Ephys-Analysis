function [Matrix_With_Contours]=Contour_Matrix_Parse(Contour_Matrix,Size_of_original_matrix);
    Matrix_With_Contours=zeros(Size_of_original_matrix(1),Size_of_original_matrix(2));
    z=1;
    counter=0;
    place=1;
    while place<size(Contour_Matrix,2)
        z=Contour_Matrix(2,place);
        for i=1:z
           Matrix_With_Contours(floor(Contour_Matrix(2,i+place)),floor(Contour_Matrix(1,i+place)))=Contour_Matrix(1,place);
           i
           
        end
        counter=counter+1;
        place=z+place+1;     
        
        
        
        
    end
end