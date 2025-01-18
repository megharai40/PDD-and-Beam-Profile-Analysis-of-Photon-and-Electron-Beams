clear all
%PDD analysis of 6 MeV beam
%interp1
clc
clear
T = readtable('path/to/excelfile', 'Sheet', '6MeV'); 
A = table2array(T);
[a,b] = size(A);
depth = A(:,1);
dose = A(:,2);

%surface dose
s_dose = dose(1)

%depth of maximum dose %SINCE PDD MAX IS 100
dmax_idx = max(find(dose==100));
dmax = depth(dmax_idx);


%depth of 90 dose
d90_interp = interp1(dose(14:37),depth(14:37),90,'linear') %doesn't work because sample
%point must be unique
%[~, d90_idx] = min(abs(dose(dmax_idx:a)-90));
%d90 = depth(dmax_idx+d90_idx-1);

%depth of 50 dose
d50 = interp1(dose(14:37),depth(14:37),50,'linear')

%[~, d50_idx] = min(abs(dose-50));
%d50 = depth(d50_idx);

plot(depth,dose,'LineWidth',3);
hold on;
x = [s_dose,max(dmax),d50];
y = [dose(1,1), 100, 50];
%labels = {'surface dose','dmax','d50'};
%text(x,y,labels);


%fit a straight line near R50 point and get slope and y-intercept
coeff = polyfit(depth(20:30), dose(20:30), 1);

line1 = coeff(1)*depth + coeff(2);
plot(depth(10:35),line1(10:35),'k:','linewidth',2);
plot(d50,50, 'o','LineWidth',3)
text(d50,50,"\leftarrow R50 ("+d50+"mm)")

%fit a straight line into bremsstrahlung tail
bremss = depth(find(dose == dose(end)));
bremss_dose = dose(dose == dose(end));
coeff2 = polyfit(bremss, bremss_dose, 1);
line2 = coeff2(1)*depth + coeff2(2);

plot(depth, line2,'--')
arrx = (45-min(depth))/(max(depth)-min(depth));
arry1 = (15-min(dose))/(max(dose)-min(dose));
arry2 = (30-min(dose))/(max(dose)-min(dose));
annotation('arrow',[arrx arrx],[arry2 arry1]);
text(42,30,"Bremsstrahlung"+newline+"          Tail")

%find Rp by solving both line equations, y2  = 0.7
Rp = (dose(end)-coeff(2))/coeff(1);
plot(Rp,0,'o','LineWidth',2);

text(Rp-12,5,"Rp (30.7mm)")
%annotation('textarrow',[0.3 0.5],[0.6 0.5],'String','Practical Range')


%Rmax 
for i = 1:a
    if dose(i) == dose(end)
        Rmax = depth(i);
        break
    end
end

plot(Rmax,0,'o','LineWidth',2)
text(Rmax-1,5,"\downarrow")
text(Rmax-5,10,"Rmax ("+Rmax+"mm)")

%plot details
text(12,100,"\leftarrow dmax ("+depth(12)+"mm)")
axis([0 max(depth) 0 105]);
grid();
xlabel("Depth (mm)")
ylabel("% Dose")
title("PDD curve for 6 MeV Electron Beam")
hold off;
