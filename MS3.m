Leds = {'Red'; 'IR'; 'Green'};
wavelengths = [660 880 527];
powers = [9.8 6.5 17.2].*1e-3;
warning off
zPos = zeros(101,101,length(wavelengths));
for i = 1:length(Leds)
    wavelength = wavelengths(i);
    [zPos(:,:,i),model] = MCrun(wavelength);
    figs = findobj('Type', 'figure'); % Find all open figures
    for j = 1:length(figs)
        saveas(figs(j), sprintf('%s_Fig%.0f.png', string(Leds(i)),j)); % Save each figure as a PNG
    end
    close all
end

%% power analysis
detOff_mm = 0.4; % sensor offset in mm
detX_mm = 1.38; % sensor x width in mm
detY_mm = 0.98; % sensor y length in mm
detArea = detY_mm * detX_mm; % detector area in mm^2
detArea = detArea * 1e-2; % mm^2 to cm^2

% conversion to indices
mmPerIdx_x = model.G.Lx*10/model.G.nx;
mmPerIdx_y = model.G.Ly*10/model.G.ny;
mmPerIdx_z = model.G.Lz*10/model.G.nz;

detOff = round(detOff_mm/mmPerIdx_x);
detX = round(detX_mm/mmPerIdx_x);
detY = round(detY_mm/mmPerIdx_y);

% identifying area of interest
origin = (length(zPos)-1)/2;

ROI_x = origin + detOff: origin+ detOff+detX;
ROI_y = origin - round(detY/2) : origin + round(detY/2);

% calculating power
avFluence = zeros(1,length(wavelengths));
pDet = avFluence;
for i = 1:length(wavelengths)
    avFluence(i) = mean(zPos(ROI_x,ROI_y,i),"all");
    pDet(i) = powers(i) * avFluence(i) * detArea;
end

pDet = pDet.* 1e3; % W to mW

% display results
for i = 1:length(Leds)
fprintf('The %s LED results in the detection of %.4f mW\n',string(Leds(i)),pDet(i))
end
