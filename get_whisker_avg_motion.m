function [avgMotion, wskTS, videoFileName] = get_whisker_avg_motion(whisker_motion)

mouseName = 'NXJF00032022';
sessionName = '090424b';
expDate = sessionName(1:end-1);

vData_path = ['Z:\Ninglong\whisker_video\Behavior_Imaging_whisker_video\' mouseName filesep expDate];
dataPrefix = 'Dend1b';

avgMotion = {}; wskTS = {}; videoFileName = {}; count=0;
for i=1:length(whisker_motion)
    vFname = whisker_motion(i).video_file_name;
    if strncmpi(vFname, dataPrefix, length(dataPrefix))
        count=count+1;
        avgMotion{count} = whisker_motion(i).avg_speed;
        wskTS{count} = whisker_motion(i).seq_ts;
        videoFileName{count} = [vData_path filesep vFname];
        if count>1
            if numel(avgMotion{count})> numel(avgMotion{count-1})
                avgMotion{count}(numel(avgMotion{count-1})+1:end)=[];
                wskTS{count}(numel(avgMotion{count-1})+1:end) = [];
            elseif numel(avgMotion{count})< numel(avgMotion{count-1})
                avgMotion{count-1}(numel(avgMotion{count})+1:end)=[];
                wskTS{count-1}(numel(avgMotion{count})+1:end)=[];
            end
        end
    end
end