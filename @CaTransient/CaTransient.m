% Class for individual calcium transients
% NX Feb 2009
%
classdef CaTransient < handle
    properties
        sessionName = '';
        animalName = '';
        %ImageFieldName = '';
        TrialID = [];
        ROI_ID = [];
        CompartmentType = ''; 
        timeStamp = [];
        deltaFF = [];
        peak = [];
        peak_time = [];
        local_max = [];
        local_max_time = [];
        rise_TC = []; % rise time constant
        decay_TC = []; % decay time constant
        rise_time = []; % 10-90%
        decay_time = []; % 90-10%
        halfwidth = [];
        area = [];
    end;
    
    methods
        function obj = CaTransient(CaTraceObj)
            obj.sessionName = CaTraceObj.sessionName;
            obj.animalName = CaTraceObj.animalName;
            obj.TrialID = CaTraceObj.TrialID;
            obj.ROI_ID = CaTraceObj.ROI_no;
            obj.CompartmentType = CaTraceObj.CompartmentType;
            t = CaTraceObj.timeStamp;
            y = CaTraceObj.deltaFF;
            
            if ~ishandle(CaTraceObj.trace_plot_handle)
                [Ca_trace_fig, trace_plot] = CaTraceObj.plot_CaTrace;
            %    CaTraceObj.trace_plot_handle = Ca_trace_fig;
            else
                figure(CaTraceObj.trace_plot_handle);
            end;
            % manually determine the Ca transient signal, by drawing a rectangle
            r = getrect(CaTraceObj.trace_plot_handle);
            line([r(1),r(1), r(1)+r(3) r(1)+r(3), r(1)], [r(2),r(2)+r(4), r(2)+r(4), r(2),r(2)],...
                'Color','g','LineWidth',2);
            % get the index for the selected period
            idx = (find(t>r(1), 1, 'first'):find(t<r(1)+r(3),1,'last'));
            
            Threshold = 0.1; % 10% of delatF/F
            t = t(idx); y = y(idx);
            obj.timeStamp = t;
            obj.deltaFF = y;
            obj.peak = max(y);
            obj.peak_time = t(y==max(y));
            [lmval, indd] = lmax_pw(y', 2); % get local maxima, dx = 2 frames.
            obj.local_max = lmval(lmval>Threshold);
            obj.local_max_time = t(indd(lmval>Threshold));
            
            t1 = t(find(y >= obj.peak/2, 1,'first'));
            t2 = t(find(y >= obj.peak/2, 1,'last'));
            obj.halfwidth.t1 = t1;
            obj.halfwidth.t2 = t2;
            obj.halfwidth.value = t2-t1;
            obj.area = trapz(t,y);
            
            rise_t1 = t(find(y >= obj.local_max(1)*0.1 ...
                & t < obj.local_max_time(1), 1, 'first'));
            rise_t2 = t(find(y >= obj.local_max(1)*0.9 ...
                & t < obj.local_max_time(1), 1, 'first'));
            decay_t1 = t(find(y >= obj.local_max(end)*0.9 ...
                & t > obj.local_max_time(end), 1, 'last'));
            decay_t2 = t(find(y >= obj.local_max(end)*0.1 ...
                & t > obj.local_max_time(end), 1, 'last'));
            obj.rise_time = rise_t2 - rise_t1;
            obj.decay_time = decay_t2 - decay_t1;
        end
        
        
        function [h] = plot_Transient(obj)
            p = get(gcf, 'Position');
            pos = [15, p(2)-300, 550, 300]; 
            h = [];
            t = obj.timeStamp;
            y = obj.deltaFF;
            t1 = obj.halfwidth.t1;
            t2 = obj.halfwidth.t2;
            h.fig = figure('Position', pos); hold on;
            h.plot = plot(t, y);
            h.maxima = plot(obj.local_max_time, obj.local_max, '*r');
            line([t1, t2; t1, t2], [0 0 ; y(t==t1) y(t==t2)], 'Color','m','LineWidth',2);
        end
    end
end
            
       