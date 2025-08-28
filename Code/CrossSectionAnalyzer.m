% Barley stems
% Takes images of barley stem sections and returns measurable parameters 
% Reisha D. Peters (2019) University of Saskatchewan
% 1 mm = 678 pixels
% 1 pixel = 0.00147547 mm

files=dir('*.png');
i=0;
tic
% for file = files'

    i=i+1; % counter
    % Upload each file
    %filename=file.name;
    filename='L183.jpg';
    % filename='InvertedThick1.png';
    % filename='InvertedThick2.png';
    % filename = 'Thick.png';
    % filename = 'Thin.png';
    I=imread(filename);
    %I=imresize(I,0.25);
    figure(1), imshow(I)
    
    % Convert to grayscale and binary image
    J=rgb2gray(I);
    K=im2bw(J,0.3);
    imshow(K)
    %K(:,1000:end)=0;
    
    % Dilation and Erosion
    K=imerode(K,ones(10));
    K=imdilate(K,ones(10));
    
    % Isolate the largest object in the image and find its edge
    stats=regionprops(K);
    cc=bwconncomp(K);
    P=[stats.Area];
    Pixels=cc.PixelIdxList{find(P==max(P))};
    K(:,:)=0;
    K(Pixels)=1;
       
    
    % Isolate the inner circle and find the edge
    notcc=bwconncomp(~K);
    stats=regionprops(~K);
    notP=[stats.Area];
    notPixels=notcc.PixelIdxList{find(notP==max(notP))};
    M=~K;
    M(notPixels)=0; % Remove the portion outside the big cirlce
    notcc=bwconncomp(M);
    stats=regionprops(M);
    notP=[stats.Area];
    notPixels=notcc.PixelIdxList{find(notP==max(notP))};
    M(:,:)=0;
    M(notPixels)=1;
    
    % Show the binary image and the boundaries in red and green
    [x,y]=ind2sub([size(J,1),size(J,2)],Pixels);
    [notx,noty]=ind2sub([size(J,1),size(J,2)],notPixels);

    figure(2), imshow(K)
    boundary=bwtraceboundary(K,[x(1),y(1)],'N');
    inboundary=bwtraceboundary(M,[notx(1),noty(1)],'N');
    hold on;
    plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);
    plot(inboundary(:,2),inboundary(:,1),'r','LineWidth',3);
    hold off
    figure (1), hold on
    plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);
    plot(inboundary(:,2),inboundary(:,1),'r','LineWidth',3);
    hold off

    % Calculations for radius and thickness
    x1=boundary(:,2);
    y1=boundary(:,1);
    x2=inboundary(:,2);
    y2=inboundary(:,1);
    repx1=repmat(x1,[1,size(x2)]); % Generating square arrays for calcs
    repx2=repmat(x2,[1,size(x1)]);
    repy1=repmat(y1,[1,size(x2)]);
    repy2=repmat(y2,[1,size(x1)]);
    repx1x1=repmat(x1,[1,size(x1)]);
    repy1y1=repmat(y1,[1,size(y1)]);
    repx2x2=repmat(x2,[1,size(x2)]);
    repy2y2=repmat(y2,[1,size(y2)]);
    % distance between all points on the two boundaries
    minTarry=sqrt((repx1-repx2').^2+(repy1-repy2').^2)*0.00147547*4; 
    % distance between all points on the outer boundary
    outerRadarry=sqrt((repx1x1-repx1x1').^2+(repy1y1-repy1y1').^2)*0.00147547/2*4;
    % distance between all points on the inner boundary
    innterRadarry=sqrt((repx2x2-repx2x2').^2+(repy2y2-repy2y2').^2)*0.00147547/2*4;
    minthick(i)=min(min(minTarry)); 
    outerrad(i)=max(max(outerRadarry));
    innerrad(i)=max(max(innterRadarry));
    % show max diameters and min thicknessess
    [minx,miny]=find(minTarry==minthick(i),1);
    [outx,outy]=find(outerRadarry==outerrad(i),1);
    [inx,iny]=find(innterRadarry==innerrad(i),1);
    figure(1), hold on
    plot([x1(minx),x2(miny)],[y1(minx),y2(miny)],'--b','Linewidth',2);
    plot([x1(outx),x1(outy)],[y1(outx),y1(outy)],'--g','Linewidth',2);
    plot([x2(inx),x2(iny)],[y2(inx),y2(iny)],'--r','Linewidth',2);
    scatter(mean(y),mean(x),15,'filled');
    legend('Outer Boundary','Inner Boundary','Minimum Thickness','Outer Diameter','Inner Diameter','Centroid');
    hold off
    % Modulus of Inertia and Section Modulus Calculations
    MIx(i)=size(x,1)*sum((x-mean(x)).^2);
    MIy(i)=size(y,1)*sum((y-mean(y)).^2);
    SecModx(i)=size(x,1)*sum((x-mean(x)).^2)/max(abs(x-mean(x)));
    SecMody(i)=size(y,1)*sum((y-mean(y)).^2)/max(abs(y-mean(y)));
        outfile=['Processed/',filename];
    saveas(figure(1), outfile);
toc
% end

DataOut=struct('Sample1',files,'MinThickness',minthick','OuterRad',outerrad','InnerRad',innerrad,'MIx',MIx,'MIy',MIy,'SecModx',SecModx,'SecMody',SecMody);
