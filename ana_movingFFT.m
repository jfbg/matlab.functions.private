function ana_movingFFT(eventtime,station,channel,despike,SAVE,nocut,tRANGE)
%
% ana_movingFFT(eventtime,station,channel,despike,SAVE,tRANGE)
%
% ana_movingFFT plots the a running Fast Fourier over the whole signal with
% the parameters described below.
%
% Inputs:   eventtime = filename for the event
%           station (12, 14, 15 or 16)
%           channel (lpx, lpy, lpz or spz)
%           rRANGE is time range requested (eg [0 20]) in minutes
%           depsike = 0 or 1 (some date is despiked). 0 is default.
%           nocut = 0 if you want to use default parameter or 1 if you do
%                   not want the signal to be cut at both ends to get rid
%                   of spikes (see below)
%
% Parameters for the moving FFT:
% 
%           - window length = 401 for LP and 401*8+1 for SP
%           - cutend = 400 (LP) or 1700 (SP) (points are cut from the end
%                   to avoid spikes.
%           - fac = 40; FFT only calculated for each 'fac' events.
%
%
%   TO FIX: cutend doesn't work, so if you have bug spikes that obscur the
%   signal, you'll have to fix the code.
%
% Created by JFBG on 23-MAR-2010






if nargin < 5 
    SAVE = 0;
    nocut = 0;
    [t sig] = getGFS(eventtime,station,channel,despike);
elseif nargin < 6
    nocut = 0;
    [t sig] = getGFS(eventtime,station,channel,despike);
elseif nargin < 7
    [t sig] = getGFS(eventtime,station,channel,despike);
else
    [t sig] = getGFS(eventtime,station,channel,despike,tRANGE);
end


t = t/60;       % time in minutes
wLP = 401;      % Window length

fac = 40;       % fac = 1 will take a fft at each point in sig, fac = 2 at 
                %      every 2 pts, etc.
if nocut == 0;                
    cutend = 400;   % How much data point to cut from end (often spikes at end);
else
    cutend = 0;
end
                



if strcmp(channel,'spz') == 1
        wLP = wLP*8+1;
        cutend = 1700;  %How much data point to cut from end (often spikes at end);
        fac = fac*8;
end
        



N = length(sig);
dt = mean(diff(t*60));

              
               
index = (1:fac:N-(wLP-1)) + (wLP-1)/2;
w = (-(wLP-1)/2:(wLP-1)/2)*1/(wLP*dt);

Fa = NaN(wLP,length(index));
Fp = NaN(wLP,length(index));
for i = 1:length(index)

    A = fft(hann(wLP) .* detrend(sig(index(i) - (wLP-1)/2 : index(i) + (wLP-1)/2)));
    Fa(:,i) = fftshift(abs(A))/wLP;
    Fp(:,i) = atan2(imag(A),real(A));

end



newt = t(index);
               

figure
set(gcf,'PaperOrientation','landscape','PaperPositionMode','auto')

subplot(4,1,1)
plot(t,sig)
xlabel('Time (min)')
title([num2str(eventtime) ' - ' num2str(station) ' - ' channel])
xlim([min(newt) max(newt)])


subplot(4,1,2:4)    
imagesc(newt,w,(Fa).^.5)  %.*(Fa > mean(mean(abs(Fa)))))    
xlim([min(newt) max(newt)])
ylim([0 max(w)])
set(gca,'ydir','normal')
% colormap(jet)
% colorbar('SouthOutside')
ylabel('Frequency (Hz)')
xlabel('Time (min)')

if SAVE == 1
    saveas(gcf,sprintf('mFFT_%11.0f_%.2f_%s.png',eventtime,station,channel),'png')
end

                
                

                
                
             
            

        