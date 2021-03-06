function out = LOG2GFS(in)

% Takes in a list of event dates in the Lognonne format (YYMMDDHHMM) and
% output the event time in GFS format.


%%
GFS = load('EventsDates.txt');
% Columns
% YY DDD HHHH(start) HHHH(end)

out = nan(size(in));

tempLOG = floor(in/1e4)+19e6;
tempLOG2 = doy(tempLOG);

year = floor((tempLOG2 - 19e5)/1e3);
day = (tempLOG2 - 19e5) - year*1e3;
hour = in - floor(in/1e4)*1e4;
hour10 = floor(hour/1e2) + (hour - floor(hour/1e2)*1e2)/60;

for i = 1:length(in)
    
    temphour1 = GFS(GFS(:,1) == year(i) &...
                        GFS(:,2) == day(i),3);
                    
    temphour = floor(temphour1/1e2) + (temphour1 - floor(temphour1/1e2)*1e2)/60;
                    
%    = searchclosest(GFS(list_index,3),hour(i));
    
    difftime = abs(temphour - hour10(i));
    [v, ind] = min(difftime);
    
    out(i) = 19e9 + year(i)*1e7 + day(i)*1e4 + temphour1(ind);
    
end


