function kmDataFlat = flattenKMData(kmData, keypoints, fps, condition, segments)
	kmDataFlat = [];
	for d = 1:length(kmData)
		km_flat = struct();
		kmData(d) = kinematicsProcessor(kmData(d), ...
											 keypoints, fps);
		km_flat.fileID = kmData(d).fileID;
		km_flat.fps = kmData(d).fps;
		km_flat.tag = kmData(d).tag;
		km_flat.condition = condition{kmData(d).condition + 1};
		km_flat.timePostCNO = kmData(d).timePostCNO;
		km_flat.pullingBout = kmData(d).pullingBout;
		for kp = 1:length(keypoints)
			km_flat.([keypoints{kp}, '_avgVelocity']) = mean(kmData(d).(keypoints{kp}).relVelocity);
			km_flat.([keypoints{kp}, '_avgXVelocity']) = mean(kmData(d).(keypoints{kp}).relXVelocity);
			km_flat.([keypoints{kp}, '_avgYVelocity']) = mean(kmData(d).(keypoints{kp}).relYVelocity);
			for seg = 1:length(segments)
				km_flat.([keypoints{kp}, '_', segments{seg}, '_avgVelocity']) = mean(kmData(d).(keypoints{kp}).(segments{seg}).relVelocity);
				km_flat.([keypoints{kp}, '_', segments{seg}, '_avgXVelocity']) = mean(kmData(d).(keypoints{kp}).(segments{seg}).relXVelocity);
				km_flat.([keypoints{kp}, '_', segments{seg}, '_avgYVelocity']) = mean(kmData(d).(keypoints{kp}).(segments{seg}).relYVelocity);
			end
		end
		kmDataFlat = [kmDataFlat; km_flat];
	end;
end