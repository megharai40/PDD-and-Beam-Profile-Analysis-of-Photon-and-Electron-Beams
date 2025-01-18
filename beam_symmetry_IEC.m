%PDD and beam profile analysis of 6 MV beam
T = readtable('New Microsoft Excel Worksheet (4)', 'Sheet', '6X');
A = table2array(T);

%defining depth and dose columns for PDD
depth = A(:,1);
dose = A(:,2);

%assigning relevant columns for beam profile (in plane and cross plane)
dist1 = A(:,4);
dose1 = A(:,5);
dist2 = A(:,7);
dose2 = A(:,8);

%deleting all NaN elements from relevant columns
dist1(isnan(dist1)) = [];
dose1(isnan(dose1)) = [];

dist2(isnan(dist2)) = [];
dose2(isnan(dose2)) = [];

beam_sym_in = [];
beam_sym_cross = [];
%Beam symmetry
k=0;
for i=1:length(dose1)
    beam_sym_in = [beam_sym_in, abs(dose1(i)/dose1(end-k))*100];
    k=i;
end
beamsym_in = max(beam_sym_in)
k=0;
for i=1:length(dose2)
    beam_sym_cross = [beam_sym_cross, abs(dose2(i)/dose2(end-k))*100];
    k=i;
end
beamsym_cross = max(beam_sym_cross)

%beam flatness DEFINED IN CENTRAL 80% OF THE FIELD SIZE
%normalising dist to find central 80% region

dose1_norm = (dose1 - min(dose1))/(max(dose1)-min(dose1))*100;
dose2_norm = (dose2 - min(dose2))/(max(dose2)-min(dose2))*100;

dose1_fwhm = dose1(dose1_norm>=49);
dose2_fwhm = dose2(dose2_norm>=49);

dist1_fwhm = dist1(dose1_norm>=49);
dist2_fwhm = dist2(dose2_norm>=49);

%central 80% defined within geometric field size
dist1_norm = dist1_fwhm/max(dist1_fwhm)*100;
dist2_norm = dist2_fwhm/max(dist2_fwhm)*100;

cen_80_in = dose1_fwhm(abs(dist1_norm)<=80);
cen_80_cross = dose2_fwhm(abs(dist2_norm)<=80);

beam_flat_in = (max(cen_80_in)-min(cen_80_in))/(max(cen_80_in)+min(cen_80_in))*100
beam_flat_cross = (max(cen_80_cross)-min(cen_80_cross))/(max(cen_80_cross)+min(cen_80_cross))*100

%plotting
hold on
plot(dist1,dose1_norm,'linewidth',2);
plot(dist1_fwhm, ones(1,length(dist1_fwhm))*50,"k--")
text(50,50, "\leftarrow Field Size");
text(-40,10, "Central 80% of FWHM")
a = dist1_fwhm(abs(dist1_norm)<=80);
b = dist2_fwhm(abs(dist2_norm)<=80);
xregion(a(1),a(end));
grid();
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
xlabel("Off Axis Distance (mm)")
ylabel("% Dose")
title("Beam Profile for 6 MV Photon Beam")
axis([-100 100 0 120]);
hold off

