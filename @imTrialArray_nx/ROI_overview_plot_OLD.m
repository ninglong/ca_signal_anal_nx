function ROI_overview_plot(obj, doppt, ppt_filename)
            if nargin < 2
                doppt = 0;
            end
            if nargin < 3
                ppt_filename = obj.PPT_filename;
            end
            eventsParam = obj.get_ROI_events_param;
            color_sc1 = [min(min(eventsParam(2).peaks(:)), min(eventsParam(3).peaks(:)))*0.7 ...
                max(max(eventsParam(2).peaks(:)), max(eventsParam(3).peaks(:)))*0.7];
            fig1 = roi_overview_color_plot(eventsParam(2).peaks,...
                'Events Peak in Stim Epoch',color_sc1); % 'Stim Epoch'
            fig2 = roi_overview_color_plot(eventsParam(3).peaks,...
                'Events Peak in Reward Epoch',color_sc1); % 'Reward Epoch'
            
            avg1 = eventsParam(2).peak_mean; se1 = eventsParam(2).peak_se;
            avg2 = eventsParam(3).peak_mean; se2 = eventsParam(3).peak_se;
            avg3 = eventsParam(1).peak_mean; se3 = eventsParam(1).peak_se;
            ystr = 'Peak dF/F (%)'; %'Event Probability'; %
            xstr = 'ROI #';
            legstr = {'Stim', 'Reward', 'Pre-Stim'};
            
            % plot trial averaged parameters for different ROIs
            fig3 = figure('Position',[900 300 500 260]); hold on;
            h(1) = errorbar(avg1, se1, 'o-');
            h(2) = errorbar(avg2, se2, 'r-o');
            h(3) = errorbar(avg3, se3, 'g-o');
            set(gca, 'FontSize', 15);
            xlim([0 length(avg1)])
            ylabel(ystr, 'FontSize', 18);
            xlabel(xstr, 'FontSize', 18);
            legend(legstr, 'FontSize', 15);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            color_sc2 = [min(min(eventsParam(2).numEvent(:)), min(eventsParam(3).numEvent(:))) ...
                max(max(eventsParam(2).numEvent(:)), max(eventsParam(3).numEvent(:)))];
            fig4 = roi_overview_color_plot(eventsParam(2).numEvent,...
                'Number of Events in Stim Epoch',color_sc2); % 'Stim Epoch'
            fig5 = roi_overview_color_plot(eventsParam(3).numEvent,...
                'Number of Events in Reward Epoch',color_sc2); % 'Reward Epoch'
%             fig5 = roi_overview_color_plot(eventsParam(4).numEvent,...
%                 'Number of Events in whole trial',color_sc2);
            
            avg1 = eventsParam(2).numEvent_mean; se1 = eventsParam(2).numEvent_se;
            avg2 = eventsParam(3).numEvent_mean;  se2 = eventsParam(3).numEvent_se;
            avg3 = eventsParam(1).numEvent_mean;  se3 = eventsParam(1).numEvent_se;
            ystr = 'Event Probability'; %'Peak dF/F (%)'; %
            xstr = 'ROI #';
            legstr = {'Stim', 'Reward', 'Pre-Stim'};
            
            % plot trial averaged parameters for different ROIs
            fig6 = figure('Position',[900 300 500 260]); hold on;
            h(1) = errorbar(avg1, se1, 'o-');
            h(2) = errorbar(avg2, se2, 'r-o');
            h(3) = errorbar(avg3, se3, 'g-o');
            set(gca, 'FontSize', 15);
            xlim([0 length(avg1)])
            ylabel(ystr, 'FontSize', 18);
            xlabel(xstr, 'FontSize', 18);
            legend(legstr, 'FontSize', 15);
            if doppt == 1
                saveppt2(ppt_filename, 'figure',[fig1,fig2,fig3,fig4,fig5,fig6], 'columns',3);
            end
            
            
            function fig = roi_overview_color_plot(param, title_str, clr_sc)
                if nargin < 3
                    clr_sc = [-10 200];
                end
%                 cscale = [-10 200];
                fig = figure('Position',[30   240   480   580]);
                imagesc(param); colorbar; caxis(clr_sc); set(gca, 'FontSize',12);
                colormap('Hot');
                xlabel('ROI #', 'FontSize', 15);
                ylabel('Trial #', 'FontSize', 15);
                title(title_str, 'FontSize', 18);
                set(gca,'YDir','normal');
            end
            
        end