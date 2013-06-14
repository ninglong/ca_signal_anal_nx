function [trace_mean, trace_se] = get_traces_and_plot(CaObj, ROInum, plotting_flag, whiskerTrials, whiskerID,sorting)
    eventTimes = CaObj.get_behavTiming;
    polePos_colors = color_go_pos(CaObj);
    switch plotting_flag
        case 0 % get and plot Ca traces
            [Traces, ts] = CaObj.get_CaTraces(ROInum,'asis');
        case 1 % get and plot whisker mean curvature traces
            if ~isempty(whiskerTrials)
                [Traces, ts] = whiskerTrials.get_whisker_traces('curvature',whiskerID);
            end
        case 2 % get and plot whisker velocity traces
            if ~isempty(whiskerTrials)
                [Traces, ts] = whiskerTrials.get_whisker_traces('velocity',whiskerID);
            end
    end
    h_hit = cplot_Ca_behav_trials(Traces,ts,eventTimes.lick, ...
        eventTimes.poleOnset, eventTimes.answerLick, h_axes1,color_sc,polePos_colors);
    set(h_axes1,'Box','off', 'FontSize',13);
    if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
        [traces_hit_align, ts1] = align_traces(CaTraces, ts, answerT_sort_hit);
        hit_mean = mean(traces_hit_align,1);
    else
        hit_mean = mean(CaTraces, 1);
        hit_se = std(CaTraces,0, 1)./sqrt(size(CaTraces,1));
    end