function kmDataFlat = flattenKMData(kmData, keypoints, conditions, segments)
	kmDataFlat = [];
	for d = 1:length(kmData)
		km_flat = struct();
		fileID = kmData(d).fileID;
		tag = kmData(d).tag;
		condition = conditions{kmData(d).condition + 1};
		timePostCNO = kmData(d).timePostCNO;
		pullingBout = kmData(d).pullingBout;
		trialTime = kmData(d).trialTime;
		fps = kmData(d).fps;
		pos1 = kmData(d).pos1;
		pos2 = kmData(d).pos2;
		pos3 = kmData(d).pos3;
		for kp = 1:length(keypoints)
			avgDistance_kp = mean(kmData(d).(keypoints{kp}).relDist);
			avgVelocity_kp = mean(kmData(d).(keypoints{kp}).relVelocity);
			avgXVelocity_kp = mean(kmData(d).(keypoints{kp}).relXVelocity);
			avgYVelocity_kp = mean(kmData(d).(keypoints{kp}).relYVelocity);
			for seg = 1:length(segments)
				km_flat.fileID = fileID;
				km_flat.tag = tag;
				km_flat.condition = condition;
				km_flat.timePostCNO = timePostCNO;
				km_flat.pullingBout = pullingBout;
				km_flat.trialTime = trialTime;
				km_flat.fps = fps;
				km_flat.pos1 = pos1;
				km_flat.pos2 = pos2;
				km_flat.pos3 = pos3;
				km_flat.totalAvgDistance = avgDistance_kp;
				km_flat.totalAvgVelocity = avgVelocity_kp;
				km_flat.totalAvgXVelocity = avgXVelocity_kp;
				km_flat.totalAvgYVelocity = avgYVelocity_kp;
				km_flat.keypoint = keypoints{kp};
				km_flat.segment = segments{seg};
				km_flat.segmentAvgDistance = mean(kmData(d).(keypoints{kp}).(segments{seg}).relDist);
				km_flat.segmentAvgVelocity = mean(kmData(d).(keypoints{kp}).(segments{seg}).relVelocity);
				km_flat.segmentAvgXVelocity = mean(kmData(d).(keypoints{kp}).(segments{seg}).relXVelocity);
				km_flat.segmentAvgYVelocity = mean(kmData(d).(keypoints{kp}).(segments{seg}).relYVelocity);
				kmDataFlat = [kmDataFlat; km_flat];
			end
		end
		
	end;
end