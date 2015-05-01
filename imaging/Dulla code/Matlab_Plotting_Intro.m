%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Matlab Plotting Tutorial                       %
%                             7-2-2009                                    %
%                       Chris Dulla                                       %                              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% OPEN A PCLAMP FILE %%%%%%%%%%%%%% 
[filename pathname] = uigetfile('*.abf','Matlab is SO SWEET!!!!', '/mnt/m022a');
filepath = strcat(pathname,filename)
[d,si,sw,tags,et,cn]= abfload2(filepath);

%d= data read, with format depending on the recording mode (gap free or episodic)
%si= sample interval in microseconds
%tags= tag information: time (s), episode #, tag text
%et= episode times(s)
%cn= optional input parameter
si = si /1e3; %converting the sample interval (measured in microseconds) to milliseconds

%Creating a matrix containing 2 Columns: time (ms) and amplitude
%Select the first and last sweep of the episodic abf file and assign it as the
%variable 'sweep'.
sweep(:,1)=d(:,1,1);
sweep(:,2)=d(:,1,sw);

%Create an array for the x-axis time points associated with each amplitude
%value in the variable sweep. Do this by creating a column of values that
%increase by the value of si. We will be using a technique called a loop,
%which tells matlab to repeat a series of commands for a given number of
%repetitions.

for i=1:size(sweep,1);
    times(i,1)=i*si;
end


%View the first sweep by plotting the sweep amplitudes versus their appropriate
%time points.
plot(times,sweep(:,1));
%Next week: more on plotting

%%%%%%%%%%%%%  Here's the new info %%%%%%%%

close  %%%%%%  This line will close any open figures

% Create figure
figure1 = figure(1);

%%%%%  Syntax:  figure1 = a hanlde to a figure
%%%%%           figure(1) = command to create a figure numbered '1'

% Create axes
axes1 = axes('Parent',figure1)
   
%%%%%  Syntax:  axes = a hanlde to an axe
%%%%%           axes('Parent',figure1) = command to create a set of axis
%%%%%           within a figure with the handle 'figure1'

%View the first sweep by plotting the sweep amplitudes versus their appropriate
%time points.
box('on');   %%  Puts a box around the figure
hold('all');  %% Tells the figue to display everything you tell it to do

% Create multiple lines using matrix input to plot
plot1 = plot(times,sweep(:,1),'Parent',axes1);

%%%%%  Syntax:  plot1 = hanlde to a plot
%%%%%           plot = command to plot a set of data
%%%%%           times = x data
%%%%%           sweep(:,1) = y data ( all the rows of the first column
%%%%%          'Parent',axes1 = plot this data within the axes you've
%%%%%          created named 'axes1'


% Change some properties of the plot
set(plot1(1),'LineWidth',2,'Color',[1 0 0]);

%%%%%  Syntax:  set = commands used to change the properties of an object
%%%%%           plot1(1) = the first data plotted in the plot with the
%%%%%           handle 'plot1;
%%%%%           'LineWidth',2 = setting the property 'LineWidth' to 2 of the object 
%%%%%           'Color',[1 0 0]= setting the property 'Color' to [1 0 0] (RGB value) of the object 

% Set the xlimit of the current plot using fixed values
xlim([250 2750]);       %%  250 = lower limit, 2750 = upper limit


% Set the ylimit of the current plot using variable
%  Creata a variable named ybaseline which is the mean of the first 100
%  rows of the first column
y_baseline=mean(sweep(1:100,1));  

% Set the xlimit of the current plot using your variable
ylim([y_baseline-2 y_baseline+2]);

% Lets play with graph a bit to see what we can do
% Set the property 'XTick' of the axes with the handle 'axes1' to 250 to
% 2750 going 250 at a time
set(axes1,'XTick',250:250:2750);

% Label the axes something very scientific
set(axes1,'XTickLabel',{'I','L','O','V','E','M','A','T','L','A','B'});

% Create xlabel for the xaxis
xlabel('Just Hanging Out in The Blue Room');

% Create ylabel for the yaxis
ylabel('mV');

% Create title for the figure
title('The Perfect Recording');

% Create text within the figure
text('Parent',axes1,'String','\leftarrow Heres where it all went wrong',...
    'Position',[600 0 0]);

%%%%%  Syntax:  'Parent',axes1 = where do I want to put the text
%%%%%           'String','\leftarrow Heres where it all went wrong' = Tell
%%%%%           matlab the I want to put in text rather than number and the
%%%%%           the text I want to include
%%%%%           'Position',[600 0 0] = the location of where I want the
%%%%%           text to go x,y,z coordinates


% Create legend
legend(axes1,'My Favorite Recording EVER!!');

close

%%%% Ploting different types of data sets;

% Simple X versus Y
X_data=1:100;
Y_data=1:100;
plot(X_data,Y_data)
close

plot(Y_data)
close
% You don't need x data to make a plot


% Two Y's versus 1 X
Y_data_2=1:2:200;
plot(X_data,Y_data,X_data,Y_data_2);
close

% Two Y's with different numbers of values in the matrix
plot(X_data(1:50),Y_data(1:50),X_data(1:75),Y_data_2(1:75))
close

% SCATTER PLOTS

figure1 = figure(1);

% Create axes
axes1 = axes('Parent',figure1)
   
%View the first sweep by plotting the sweep amplitudes versus their appropriate
%time points.
box('on');
hold('all');

% Create some data
X_Values=1:10;
Y_Values(1,:)=1:2:20;
Y_Values(2,:)=1:3:30;

% Create multiple lines using matrix input to plot
plot1 = plot(X_Values,Y_Values,'--rs','Parent',axes1);
% New syntax '--rs' line and marker scatter plot

% Change some of the parameters of the plot
set(plot1(1),'LineWidth',5,'Color',[1 0 1],...
    'lineStyle',':', 'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10 );
set(plot1(2),'LineWidth',2,'Color',[1 1 0],...
    'lineStyle','-', 'MarkerEdgeColor','r','MarkerFaceColor','b','MarkerSize',20 );


close
%%%%  Making Figures with mulitple plots - the sloppy way
% NOTE - you don't have to use the figure command, axes command, etc
subplot(2,1,1)

% Syntax  subplot(2,1,1) = break up the current figure into 2 rows with 1
% column and go to the first cell
plot(times,sweep(:,1))

subplot(2,1,2)
% Syntax  subplot(2,1,2) = break up the current figure into 2 rows with 1
% column and go to the second cell
plot(X_Values,Y_Values,'--rs')


close

% Open some seriously scientific data
nb=open('/oj.jpg');

%%%%  Making Figures with mulitple plots - the slightly less slopy way

TraceImage=subplot(2,2,1)
% Syntax - break the current figure into 2 rows and 2 columns and go to the
% first cell

plot(times,sweep(:,1))
set(TraceImage, 'OuterPosition', [.0,.8,.4,.15])
% Syntax - set the property 'Outerposition' of the object with the handle 'TraceImage' to the coorinated
%  left, bottom width height

Scatter = subplot(2,2,2)
plot(X_Values,Y_Values,'--rs')
set(Scatter, 'OuterPosition', [.5,.8,.4,.15])

TraceImage2=subplot(2,2,3)
plot(times,sweep(:,2))
set(TraceImage2, 'OuterPosition', [.0,.1,.1,.15])

NaturalBeauty = subplot(2,2,4)
set(NaturalBeauty, 'OuterPosition', [.2,.1,.6,.7])
image(nb.oj,'cdatamapping','scaled');
           
close            


% Other Thing you can do in Matlab with plots

% 3D Stem Plots
th = (0:127)/128*2*pi;
x = cos(th);
y = sin(th);
f = abs(fft(ones(10,1),128));
stem3(x,y,f','d','fill')
view([-65 30])
close

% Contour Plots
[X,Y,Z] = peaks;
contour(X,Y,Z,20)

% Make your contour plot 3d
contour3(X,Y,Z,20)
h = findobj('Type','patch');
set(h,'LineWidth',2)
title('Twenty Contours of the peaks Function')
close



