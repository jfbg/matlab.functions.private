function [ang P SV] = rotPSV(R,Z,Sarr,lS,ROTATE)

% [ang P SV] = rotPSV(R,Z,Sarr,lS)
%
% Outputs incident angle (ang) calculated from covariance matrix of R and Z.
% Outputs rotated P and SV (if ROTATE == 1);
%
% Sarr is estimated S arrival in signal (index)
% lS is length of window from which to calculate cov matrix (Sarr:Sarr+lS)
%

%%
%%% Calculate covariance matrix
% N = length(R)-1;
% mR = R-mean(R);
% mS = Z-mean(Z);
% C = [sum(mR.*mR)/N sum(mS.*mR)/N;
%      sum(mR.*mS)/N sum(mS.*mS)/N];
% Same as:
  C = cov(R(Sarr:Sarr+lS),Z(Sarr:Sarr+lS));



%%
% Find orientation of eigenvector representing smallest variance
% This is orientation off P-axis.
  [V,D] = eig(C);
  paxis = V(:,diag(D) == min(diag(D)));

%Orientation of z-axis
  zaxis = [0; 1];

% Signed Angle from zaxis to paxis
  ang =  acosd(V(1,2));
%   aV = acosd(V);
%   if prod(aV(:,1)) < 0, ang = ang*-1; end
% %   if ang > 90, ang = 180-ang; end
% %   if ang < -90, ang = -180-ang; end


Ve = acosd(V);
tempangle = [Ve(1,1)-90 180-Ve(1,2);180-Ve(2,1) 90-Ve(2,2)];

ang = mode(abs(tempangle(:)))*sign(prod(tempangle(1,:)));

%%
  if ROTATE == 1
  
% Rotate into eigenvector by using the eigenvector matrix as the rotation
% matrix

    S1 = [R(:)';Z(:)'];
    S2 = NaN(size(S1));

    for i=1:length(S1)
        S2(:,i) = V*S1(:,i);
    end

    P = S2(1,:)';
    SV = S2(2,:)';


    else
      P = NaN;
      SV = NaN;
  end
  
%%
end