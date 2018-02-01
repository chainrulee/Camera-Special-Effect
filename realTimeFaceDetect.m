%% Setup
% Create the face detector object.
FaceDetect = vision.CascadeObjectDetector();

% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

videoFileReader = vision.VideoFileReader('face5.mov');
videoFrame      = step(videoFileReader);

% Capture one frame to get its size.
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);
%% Detection and Tracking
numPts = 0;

v = VideoWriter('faceDectect.avi');
open(v)

[obj,~,alpha] = imread('mask.png');
%[obj,~,alpha]=transparentgifread('fire.gif');
obj = double(obj);
%obj = obj(80:180,:,:);
alpha = double(alpha);
%alpha = alpha(80:180,:);
alpha(:,:,2) = alpha(:,:,1);
alpha(:,:,3) = alpha(:,:,1);
time = 0;

while ~isDone(videoFileReader)

    % Get the next frame.
    videoFrame = step(videoFileReader);
    videoFrameGray = rgb2gray(videoFrame);
    time = time +1;

    if numPts < 10 %|| mod(time,10)==0
        % Detection mode.
        bbox = FaceDetect.step(videoFrameGray);

        if ~isempty(bbox)
            % Find corner points inside the detected region.
            points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

            % Re-initialize the point tracker.
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, videoFrameGray);

            % Save a copy of the points.
            oldPoints = xyPoints;

            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners. This
            % is needed to be able to transform the bounding box to display
            % the orientation of the face.
            bboxPoints = bbox2points(bbox(1, :));

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            %bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the detected face.
            %videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display detected corners.
            %videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
        end

    else
        % Tracking mode.
        [xyPoints, isFound] = step(pointTracker, videoFrameGray);
        visiblePoints = xyPoints(isFound, :);
        oldInliers = oldPoints(isFound, :);

        numPts = size(visiblePoints, 1);

        if numPts >= 10 
            % Estimate the geometric transformation between the old points
            % and the new points.
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

            % Apply the transformation to the bounding box.
            bboxPoints = transformPointsForward(xform, bboxPoints);

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            %bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the face being tracked.
            %videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display tracked points.
            %videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');
            
            % add picture
            lenBBx = ((bboxPoints(4,2)-bboxPoints(1,2))^2+(bboxPoints(4,1)-bboxPoints(1,1))^2)^0.5;
            % eye
            %resObj = imresize(obj, [lenBBx*4 NaN], 'bilinear');
            %resAlpha = imresize(alpha, [lenBBx*4 NaN], 'bilinear');
            % ear
            %resObj = imresize(obj, [lenBBx/2 NaN], 'bilinear');
            %resAlpha = imresize(alpha, [lenBBx/2 NaN], 'bilinear');
            % mask
            resObj = imresize(obj, [lenBBx*1.7 NaN], 'bilinear');
            resAlpha = imresize(alpha, [lenBBx*1.7 NaN], 'bilinear');
            angle =  atan((bboxPoints(2,2)-bboxPoints(1,2))/(bboxPoints(2,1)-bboxPoints(1,1)))/pi*180;
            rotObj = imrotate(resObj,-angle,'bilinear');
            rotAlpha = imrotate(resAlpha,-angle,'bilinear');
            rotObj = (rotObj-min(rotObj(:)))/(max(rotObj(:))-min(rotObj(:)))*255;
            rotAlpha = (rotAlpha-min(rotAlpha(:)))/(max(rotAlpha(:))-min(rotAlpha(:)))*255;
            lenObjx = length(rotObj(:,1,1));
            lenObjy = length(rotObj(1,:,1));
            
            % mask
            cornerX = round((bboxPoints(1,2)+bboxPoints(2,2)+bboxPoints(3,2)+bboxPoints(4,2))/4-(bboxPoints(4,2)-bboxPoints(1,2))/8-lenObjx/2);
            cornerY = round((bboxPoints(1,1)+bboxPoints(2,1)+bboxPoints(3,1)+bboxPoints(4,1))/4-(bboxPoints(4,1)-bboxPoints(1,1))/8-lenObjy/2);
             %ear
             %cornerX = round((bboxPoints(1,2)+bboxPoints(2,2)+bboxPoints(3,2)+bboxPoints(4,2))/4-(bboxPoints(4,2)-bboxPoints(1,2))/4*3-lenObjx/2);
             %cornerY = round((bboxPoints(1,1)+bboxPoints(2,1)+bboxPoints(3,1)+bboxPoints(4,1))/4-(bboxPoints(4,1)-bboxPoints(1,1))/4*3-lenObjy/2);
              %eyes
             %cornerX = round((bboxPoints(1,2)+bboxPoints(2,2)+bboxPoints(3,2)+bboxPoints(4,2))/4+(bboxPoints(4,2)-bboxPoints(1,2))/4-lenObjx/2);
             %cornerY = round((bboxPoints(1,1)+bboxPoints(2,1)+bboxPoints(3,1)+bboxPoints(4,1))/4-(bboxPoints(4,2)-bboxPoints(1,2))/8-lenObjy/2);
            if cornerX < 721-lenObjx && cornerY < 1281-lenObjy && cornerX > 0 && cornerY > 0
            videoFrame(cornerX:cornerX+lenObjx-1,cornerY:cornerY+lenObjy-1,:)...
                = videoFrame(cornerX:cornerX+lenObjx-1,cornerY:cornerY+lenObjy-1,:).*(255-rotAlpha)...
                /255+rotObj.*rotAlpha/255/255;
            end            
            
            %if time >  90 && time < 180
            %    videoFrame = single(SoftFocusEffect_test(double(videoFrame)*255,round((bboxPoints(1,2)+bboxPoints(2,2)+bboxPoints(3,2)+bboxPoints(4,2))/4)...
            %        ,round((bboxPoints(1,1)+bboxPoints(2,1)+bboxPoints(3,1)+bboxPoints(4,1))/4)))/255;
            %end
            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end

    end

    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    writeVideo(v,videoFrame)
end

% Clean up.
release(videoPlayer);
release(pointTracker);
release(FaceDetect);
close(v)