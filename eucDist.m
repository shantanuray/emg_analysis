function dist = eucDist(x,varargin)
	dist = (x(2:end)-x(1:end-1)).^2;
	if nargin>1
		for v = 1:length(varargin)
			pts = varargin{v};
			dist = dist + (pts(2:end)-pts(1:end-1)).^2;
		end
	end
	dist = dist.^0.5;
	return;