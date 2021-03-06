function [R SH x y z ba] = rotRTZ2(x,y,z,station,cluster)



%% Assign spherical coord to the EVENT that is involved using the cluster
%  location and make sure that the clusters_locations.txt file contains
%  the coordinates for the cluster involved.

list = load('clusters_locations.txt');   % list of cluster with coordinates
%COLUMNS:    CLUSTER COLATITUDE LONGITUDE(degE) DEPTH(km)

% eventname = sprintf('event%03.0f',cluster);

clusterID = find(list(:,1) == cluster);

if isempty(clusterID) == 1
    error('The clusers_locations.txt file does not have the coordinates\nfor cluster %.0f. Please update the file.',cluster)
else
    eDE = list(clusterID,4);   % Depth
    eCL = list(clusterID,2);   % Colatitude
    eLO = list(clusterID,3);   % Longitude
end

%% 

% Load signals

% [tx x] = getGFS(eventtime,station,'lpx',despike);
% [ty y] = getGFS(eventtime,station,'lpy',despike);
% [tz z] = getGFS(eventtime,station,'lpz',despike); 

lx = length(x);
ly = length(y);
lz = length(z);

if lx ~= ly || lx ~= lx || ly ~= lz
    error('The 3 signals are not the same length.')
end


%% Station locations (radius, colatitude, longitude)

R = 1740e3;     % Moon Radius

% INSTRUMENT COORDINATES (ALSEP for stations 12, 14, 15 & 16, LRRR for 11)
% 
%           degN        degE
% 
% S11 :    0.67337     23.47293
% S12 :   -3.00942    -23.42458
% S14 :   -3.64398    -17.47748
% S15 :   26.13407      3.62981
% S16 :   -8.97537     15.49812

loc11 = [R 90-0.67337 23.47293];
loc12 = [R 90-(-3.00942) 360-23.42458];
loc14 = [R 90-(-3.64398) 360-17.47748];
loc15 = [R 90-26.13407 3.62981];
loc16 = [R 90-(-8.97537) 15.49812];


%% Channels orientation, clockwise from North

% Orientations
o11 = [0 90];
o12 = [180 270];
o14 = [0 90];
o15 = [0 90];
o16 = [334.5 64.5];

% Correct for right-hand rule
% o11 = [0 90+180];
% o12 = [180 270-180];
% o14 = [0 90+180];
% o15 = [0 90+180];
% o16 = [334.5 64.5+180];


%% Assign spherical coord to the STATION that is involved.

statname = sprintf('loc%2.0f',station);

eval(['sRA = ' statname '(1);'])        % Radius
eval(['sCL = ' statname '(2);'])        % Colatitude
eval(['sLO = ' statname '(3);'])        % Longitude

%% Get axis orientation for the station involved

oname = sprintf('o%2.0f',station);

eval(['X = ' oname '(1);'])
eval(['Y = ' oname '(2);'])
% +Z is always pointing up.

%% Find BACK-AZIMUTH angle
%   Angle describing the direction from which the waves arrive at the
%   seismometer, measured clock-wise from the local direction of north at
%   the seismometer to the great circle arc.

% Compute DELTA
%   distance, in degrees, between XS and XE

delta = acosd(cosd(eCL)*cosd(sCL) + sind(eCL)*sind(sCL)*cosd(sLO - eLO));

if delta == 180
    ba = 180;
else
    
% Compute BA
%   Back-azimuth

a = acosd( 1/sind(delta) * (cosd(eCL)*sind(sCL) - sind(eCL)*cosd(sCL)*cosd(eLO-sLO)));

if sind(eLO-sLO) > 0, ba = a; end
if sind(eLO-sLO) < 0, ba = 360 - a; end


end

%% Calculate DIRECTION COSINES

% R is radial axis (positive is in BA direction)
% SH is shear horizontal axis
% SV is shear vertical axis
%
% aR_X means angle from R to X

R = ba;
% SH = ba + 90;

ang = R - X;
if ang < 0, ang = 360+ang; end

% aR_X = X - R;
% aR_Y = Y - R;
% aR_Z = 90;
% 
% aSH_X = X - SH;
% aSH_Y = Y - SH;
% aSH_Z = 90;
% 
% aSV_X = 90;
% aSV_Y = 90;
% aSV_Z = 0;

% Clockwise rotation because BA is angle clockwise from north
DCOS = [cosd(ang) sind(ang);
        -sind(ang) cosd(ang)];


% DCOS = [cosd(aR_X)  cosd(aR_Y)  cosd(aR_Z);
%         cosd(aSH_X) cosd(aSH_Y) cosd(aSH_Z);
%         cosd(aSV_X) cosd(aSV_Y) cosd(aSV_Z)];
    
%% ROTATE

S1 = [x';y'];  %;z'];
S2 = NaN(size(S1));

for i=1:lx
    S2(:,i) = DCOS*S1(:,i);
end

R = S2(1,:)';
SH = S2(2,:)';
% t = tx;


% % % if PLOT == 1
% % %     
% % %     figure
% % %     subplot(311)
% % %     plot(t,x)
% % %     xlim([min(t) max(t)])
% % %     ylabel('X')
% % %     subplot(312)
% % %     plot(t,y)
% % %     ylabel('Y')
% % %     xlim([min(t) max(t)])
% % %     subplot(313)
% % %     plot(t,z)
% % %     ylabel('Z')
% % %     xlim([min(t) max(t)])
% % %     xlabel('Time (s)')
% % % 
% % %     figure
% % %     subplot(311)
% % %     plot(t,R)
% % %     xlim([min(t) max(t)])
% % %     ylabel('R')
% % %     subplot(312)
% % %     plot(t,SH)
% % %     ylabel('SH')
% % %     xlim([min(t) max(t)])
% % %     subplot(313)
% % %     plot(t,z)
% % %     ylabel('Z')
% % %     xlim([min(t) max(t)])
% % %     xlabel('Time (s)')
% % %     
% % % end
% % % 
% % % return
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
