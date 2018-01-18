function [F, inlierPts] = AutoFundamental( I1,I2,thresh,iteration )
%% feature extraction
% f has a column for each frame. A frame is a disk of center f(1:2), scale f(3) and orientation f(4)
[fa, da] = vl_sift(single(rgb2gray(I1))) ;
[fb, db] = vl_sift(single(rgb2gray(I2))) ;

[row,col,~] = size(I1); 
%% feature matching
% matches [image 1 feature point idx; image 2 feature point idx]
[matches, scores] = vl_ubcmatch(da, db) ;

% sort matches in descending order by score
[~, idx]= sort(scores,'descend');
sortMatches = [matches(1,idx);matches(2,idx)];
clear idx;

p1 = fa(1:2,sortMatches(1,:));
p2 = fb(1:2,sortMatches(2,:));

figure
imshow([I1 I2])
hold on 
plot(p1(1,1:end),p1(2,1:end),'og')
plot(col+p2(1,1:end),p2(2,1:end),'or')
hold off

%% ransac
[F,idx] = Fundamental_RANSAC(p1,p2,thresh,iteration);
[Fgt,idxgt] = estimateFundamentalMatrix(p1',p2','Method','RANSAC',...
    'NumTrials',iteration,'DistanceThreshold',thresh);
disp(F)
disp(length(idx))

%% Visualize epipolar line
p1inlier = p1(:,idx);
p2inlier = p2(:,idx);
inlierPts = [p1inlier;p2inlier];
epline2 = F * [p1inlier; ones(1,length(p1inlier))];
epline1 = F' * [p2inlier; ones(1,length(p2inlier))];


[slope1, b1] = findEpipolarLine( epline1 );
[slope2, b2] = findEpipolarLine( epline2 );

figure
imshow([I1,I2])
hold on 
for i = 1 : length(p1inlier)
plot(1:col,(slope1(i)*(1:col)+b1(i)),'-r')
plot(1+col:col*2,(slope2(i)*(1:col)+b2(i)),'-b')
end
plot(p1inlier(1,:),p1inlier(2,:),'og')
plot(p2inlier(1,:)+col,p2inlier(2,:),'og')
hold off

end


% [F,idx] = estimateFundamentalMatrix(p1',p2','Method','RANSAC',...
%     'NumTrials',2000,'DistanceThreshold',1.5);

% figure
% subplot(1,2,1)
% imshow(I2)
% hold on
% epline2 = epipolarLine(F,p1inlier');
% epline1 = epipolarLine(F',p2inlier');
% 
% points = lineToBorderPoints(epline2,size(I1));
% line(points(:,[1,3])',points(:,[2,4])');
% plot(p2inlier(1,:),p2inlier(2,:),'xr')
% 
% subplot(1,2,2)
% imshow(I1)
% hold on
% points = lineToBorderPoints(epline1,size(I2));
% line(points(:,[1,3])',points(:,[2,4])');
% plot(p1inlier(1,:),p1inlier(2,:),'xr')
