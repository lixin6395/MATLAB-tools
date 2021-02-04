classdef NURB_Curve
    % The difference between Bspline and NURB_Curve is that the NURB curve
    % contains a weight for each control points. The NURB curve generalizes
    % into a Bspline if all weights are set to 1.
    properties %(SetAccess = private)
        n % number of control points
        p % degree / order
        control_points   % matrix of control points stored as column vectors, rows=elements of control points, columns=different control points   
        weights
    end
    methods
        function obj = NURB_Curve(control_points, weights, degree)            
            obj.control_points = control_points; 
            obj.weights = weights;
            obj.n = length(obj.control_points);            
            obj.p = degree; % degree            
        end        
        
        function y = eval(obj, u)
            y = 0;
            normalizer = 0;
            for i = 0:(obj.n-1)
                activation = obj.weights(:,i+1) *  obj.basis(obj.p, i, mod(u+(obj.p+1)/2, obj.n));
                y = y + activation * obj.control_points(:,i+1); % add the degree to center the kernel
                normalizer = normalizer + activation;
            end
            y = y / normalizer;
        end
        
        function dy = deval(obj, u)
            
        end
        
        % Cox-de Boor recursion formula
        % Used to evaluate the basis function at a given u associated with
        % a particular control point, i, for a B-spline basis of order p
        % See:
        % - https://pages.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/B-spline/bspline-basis.html
        % - https://en.wikipedia.org/wiki/B-spline#Definition
        % In this simple Bspline the knots are uniform with length 1 seperation
        function B = basis(obj, p, i, u)            
            if (p == 0)                                 
                B = double(mod(u - i, obj.n) < 1);                
            else
                B = mod(u - i, obj.n) / mod(mod(i+p, obj.n) - i, obj.n) * obj.basis(p-1, i, u);

                %B = B + (obj.knots(i+p+2) - u) / (obj.knots(i+p+2) - obj.knots(i+2)) * obj.basis(p-1, i+1, u);
                B = B + (1 - mod(u - (i+1), obj.n) / mod(mod(i+p+1, obj.n) - mod(i+1, obj.n), obj.n)) * obj.basis(p-1, mod(i+1, obj.n), u);                     
                % These two lines gives the same, but the latter
                % matches the definition from Wikipedia                
            end
        end         
        
        function dB = dbasis(obj, p, i, u)            
            % dBasis / du
            if (p == 0)                                 
                dB = 0;
            else
                dB =      1 / mod(mod(i+p, obj.n) - i, obj.n) * obj.basis(p-1, i, u);
                dB = dB + mod(u - i, obj.n) / mod(mod(i+p, obj.n) - i, obj.n) * obj.dbasis(p-1, i, u);

                %B = B + (obj.knots(i+p+2) - u) / (obj.knots(i+p+2) - obj.knots(i+2)) * obj.basis(p-1, i+1, u);
                dB = dB + -1 / mod(mod(i+p+1, obj.n) - mod(i+1, obj.n), obj.n) * obj.basis(p-1, mod(i+1, obj.n), u);                     
                dB = dB + (1 - mod(u - (i+1), obj.n) / mod(mod(i+p+1, obj.n) - mod(i+1, obj.n), obj.n)) * obj.dbasis(p-1, mod(i+1, obj.n), u);                     
                % These two lines gives the same, but the latter
                % matches the definition from Wikipedia                
            end
        end               
        
        function ddB = ddbasis(obj, p, i, u)            
            % ddBasis / du
            if (p == 0)                                 
                ddB = 0;
            else
                ddB =       1 / mod(mod(i+p, obj.n) - i, obj.n) * obj.dbasis(p-1, i, u);
                ddB = ddB + 1 / mod(mod(i+p, obj.n) - i, obj.n) * obj.dbasis(p-1, i, u);
                ddB = ddB + mod(u - i, obj.n) / mod(mod(i+p, obj.n) - i, obj.n) * obj.ddbasis(p-1, i, u);

                %B = B + (obj.knots(i+p+2) - u) / (obj.knots(i+p+2) - obj.knots(i+2)) * obj.basis(p-1, i+1, u);
                ddB = ddB + -1 / mod(mod(i+p+1, obj.n) - mod(i+1, obj.n), obj.n) * obj.dbasis(p-1, mod(i+1, obj.n), u);                                                         
                ddB = ddB + -1 / mod(mod(i+p+1, obj.n) - mod(i+1, obj.n), obj.n) * obj.dbasis(p-1, mod(i+1, obj.n), u);                     
                ddB = ddB + (1 - mod(u - (i+1), obj.n) / mod(mod(i+p+1, obj.n) - mod(i+1, obj.n), obj.n)) * obj.ddbasis(p-1, mod(i+1, obj.n), u);                     
                % These two lines gives the same, but the latter
                % matches the definition from Wikipedia                
            end
        end           
        
    end
end