%PDD and beam profile analysis of 6 MV beam
clc
clear
clear all
%The first argument of readtable is the path to the excel file with raw beam data, the second and third argument specify the sheet name in the excel file to be analysed
T = readtable('path/to/excelfile', 'Sheet', '6X'); 
A = table2array(T);

%defining depth and dose columns for PDD
depth = A(:,1);
dose = A(:,2);

%replacing NaN elements with 0
%nan_elem = isnan(A); %gives a 'logical' output. 1 for if element is Nan and 0 if not.
%A(nan_elem)= 0 %replace all indices with NaN == True to 0

%assigning relevant columns for beam profile (in plane and cross plane)
dist1 = A(:,4);
dose1 = A(:,5);
dist2 = A(:,7);
dose2 = A(:,8);

%deleting all NaN elements from relevant columns
dist1 = dist1(~isnan(dist1));
dose1 = dose1(~isnan(dose1));
dist2 = dist2(~isnan(dist2));
dose2 = dose2(~isnan(dose2));
%PDD analysis of 6 MV
%surface dose
s_dose = dose(1)

%depth of maximum dose %SINCE PDD MAX IS 100
dmax_idx = find(dose==100);
dmax = depth(dmax_idx)


%depth of 50 dose
d50 = interp1(dose(20:end),depth(20:end),50,'linear')
%Analysing beam profile

%normalising beam profile data
dose1_norm = (dose1 - min(dose1))/(max(dose1)-min(dose1))*100;
dose2_norm = (dose2 - min(dose2))/(max(dose2)-min(dose2))*100;


%Beam Symmetry
%Range of dose within 50
D50_range_in = dose1_norm(dose1_norm>=49); %All normalised dose values above 50% in plane
D50_range_cross = dose2_norm(dose2_norm>=49); %All normalised dose values above 50 cross plane

dist1_50 = dist1(dose1_norm>=49); %all distance values for dose above 50 in plane
dist2_50 = dist2(dose2_norm>=49);  %all distance values for dose above 50 cross plane

%finding index of 0 axis in 50 dose range
d50_range_in_idx = find(dist1_50==0); %finding the central axis (distance ==0)
d50_range_cross_idx = find(dist2_50==0);

%assigning area of left and right field of beam profile
in_left_area = trapezoid_int(D50_range_in(1:d50_range_in_idx),dist1_50(1:d50_range_in_idx)); %integrating using trapezoid method to find area
in_right_area = trapezoid_int(D50_range_in(d50_range_in_idx:end),dist1_50(d50_range_in_idx:end));


cross_left_area = trapezoid_int(D50_range_cross(1:d50_range_cross_idx),dist2_50(1:d50_range_cross_idx));
cross_right_area = trapezoid_int(D50_range_cross(d50_range_cross_idx:end),dist2_50(d50_range_cross_idx:end));

%Beam symmetry values for in plane and cross plane
beam_sym_in = abs((in_left_area - in_right_area)/(in_left_area + in_right_area))*100
beam_sym_cross = abs((cross_left_area - cross_right_area)/(cross_left_area + cross_right_area))*100


%code for flatness in beam_symmetry_IEC

%Penumbra
dist_1_20 = dist1(dose1_norm >= 19);
dist_1_80 = dist1(dose1_norm >= 79);
penumbra_left = abs(dist_1_20(1)-dist_1_80(1))
penumbra_right = abs(dist_1_20(end)-dist_1_80(end))


%plotting PDD and Beam Profile 
hold on;
figure(1)
plot(dist1,dose1_norm);
plot(dist1(dose1_norm>=49), ones(1,length(dist1(dose1_norm>=49)))*50,"k--")
text(50,50, "\leftarrow Field Size");
grid();

a=[];
b=[];
a = [dist1_50(1);dist1_50(1:find(dist1_50==0));0];
b = [0;D50_range_in(1:find(dist1_50==0));0];
c = [0;dist1_50(find(dist1_50==0):end);dist1_50(end)];
d = [0;D50_range_in(find(dist1_50==0):end);0];

fill(a,b, 'cyan','FaceAlpha',0.3);
fill(c,d, 'red','FaceAlpha',0.3);

text(-40,70,'Area Left');
text(15,70,'Area Right');

xregion(dist1(find(dist1==-53)),dist1(find(dist1==-47)));
xregion(dist1(find(dist1==53)),dist1(find(dist1==47)));
t = text(-50,85,'Penumbra');
t.Rotation = 90;
t2 = text(50,110,'Penumbra');
t2.Rotation = 270;
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
xlabel("Off Axis Distance (mm)")
ylabel("% Dose")
title("Beam Profile for 6 MV Photon Beam")
hold off


figure(2)
hold on
plot(depth,dose,'linewidth',3)
plot(ones(1,20)*15,linspace(0,100,20),'--')
grid()
axis([0 300 0 120]);
text(depth(find(dose==100)),100,"\leftarrow dmax ("+depth(find(dose==100))+"mm)")
xlabel("Depth (mm)")
ylabel("% Dose")
title("PDD curve for 6 MV Photon Beam")
hold off;

