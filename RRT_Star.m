%%ƽ���άRRT*�㷨����������ײ·��
%%qinit:��ʼ��
%%qrand:���������
%%qnearest:����qnearest�����һ���ڵ�
%%qgoal:��ֹ��
clear all;close all;clc
%% ���ɽ�ͼ
map=~zeros(500,500);
map(230:270,50:120) = 0;
map(230:270,200:450) = 0;
map(20:100,350:400) = 0;
map(170:450,350:400) = 0;
map(350:400,20:60) = 0;
imshow(map)
[m,n] = size(map);
%% �����ʼ����,�����Ͻ�Ϊԭ������������һ������ʾy���ڶ�������ʾx
x_init = 20;y_init = 100;  %��ʼ������
x_goal = 480; y_goal = 400;%Ŀ�������
stepsize = 20;             %��������
threshold = 20;            %��ֵ,��qnearst��qgoal��ľ�������ֵ֮��ʱ���������������Ŀ���,��stepsize����ͬ��
RadiusForNer = 50;         %rewire�ķ�Χ���뾶r
MaxIterations = 2000;       %����������
display = 1;               %��ʾ��������Ϊ��
P_handleList = [];
L_handleList = [];
resHandleList= [];
%% ��������ʼ��
RRTStarTree.node(1).coord =[x_init y_init];  %���е�һ���ڵ㼴Ϊ��ʼ��
RRTStarTree.node(1).Parent = [x_init y_init] %��ʼ�ڵ�ĸ��ڵ��Ǳ���ÿ���ڵ㶼��һ����ֻ��һ�����ڵ�
RRTStarTree.node(1).Cost = 0;                %����Ϊ0
RRTStarTree.node(1).ParIndex = 0;            %��ʼ�ڵ�ĸ��ڵ���������Ϊ0
%% �ж���ʼ���Ŀ����Ƿ����Ҫ��
if feasiblePoint(RRTStarTree.node(1).coord,map) ==0
	error('��ʼ�㲻���ϵ�ͼҪ��');%%error����ĳ��򲻻ᱻִ��
end

if feasiblePoint([x_goal,y_goal],map) ==0
	error('Ŀ��㲻���ϵ�ͼҪ��');%%error����ĳ��򲻻ᱻִ��
end
%% ��ʾ��ͼ
if display
	imshow(map);
    rectangle('position',[1 1 size(map)-1],'LineWidth', 2,'edgecolor','k');
    hold on;
    scatter(RRTStarTree.node(1).coord(2),RRTStarTree.node(1).coord(1),100,'sm','filled');
    hold on;
    scatter(y_goal,x_goal,100,'sb','filled');
end
tic; %%����ʼ������ʱ��
counter = 1;       %%�ڵ���
pathFound = 0;     %%����Ŀ��㸽����־
NumIterations = 0  %%��ʾ��������
for i = 1:MaxIterations
    NumIterations = NumIterations+1
    %step1���ڵ�ͼ���������һ��x_rand
    x_rand = rand(1,2).*size(map);    %%rand(m,n) ����m��n�о��ȷֲ��ڣ�0,1���ڵ�α�����
    
    %step2��ѡ����x_rand����Ľڵ�
    for i=1:length(RRTStarTree.node)
        for j=1:2
            ExistNode(i,j) =  RRTStarTree.node(i).coord(1,j);
        end
    end
    [A,MinIndex] = min(distanceCost(ExistNode,x_rand),[],1); %%A����ǰ���ڵĽڵ���������������룬I������С������������
    closestNode = RRTStarTree.node(MinIndex).coord; %%ѡ����RRT���е�qnearst�ڵ㣬ÿ�ζ����£������ۼ�
    temp_parent = MinIndex;  %%��ʱ���ڵ������
    temp_Cost = stepsize + RRTStarTree.node(MinIndex).Cost; %%��ʱ�ۼƴ���
    
    %step3����չ�õ�x_new�ڵ�
    theta = atan2(x_rand(1)-closestNode(1),x_rand(2)-closestNode(2)); %��qrand������չһ�ξ���
    x_new = double(int32(closestNode(1:2)+stepsize*[sin(theta) cos(theta)])); %%����qneaest��qrand����ֱ�߲�����һ�ξ���,ȡ����
    %����½ڵ��Ƿ�����Χ����������ײ
    if ~checkPath(closestNode(1:2),x_new,map) %%�ж���������ڵ���չ���½ڵ�·�����Ƿ����ϰ�����ײ
        %%failedAttempts = failedAttempts+1 %�����ײ��ִ��
        continue; %��ִ��ѭ�������²��֣�ֱ�ӿ�ʼ�´�ѭ����������½ڵ����ϣ����¸�ֵ��������ǰ�β�������������
    end
    
    %step4����x_newΪԲ��,�뾶ΪR��Բ���������������Ľڵ� 
    Dis_NearToNewList= [];          %%ÿ��ѭ��Ҫ��֮ǰ�����ֵ���
    Index_NearToNewList = [];
    for i = 1:counter
        Dis_NearToNew = distanceCost(x_new,RRTStarTree.node(i).coord);
        if (Dis_NearToNew<RadiusForNer)
            Dis_NearToNewList = [Dis_NearToNewList Dis_NearToNew]; %%�����б�
            Index_NearToNewList =[Index_NearToNewList i];          %%�����б�
        end
    end
    
    %step5������ѡ��x_new�ĸ��ڵ� 
    for i = 1:length(Index_NearToNewList)
        Cost_InitToNew = Dis_NearToNewList(i) + RRTStarTree.node(Index_NearToNewList(i)).Cost;  %%�ܴ���=xnew��xnear�ľ���+��ǰxnear��xinit�ľ���
        if (Cost_InitToNew<temp_Cost)
            if ~checkPath(RRTStarTree.node(Index_NearToNewList(i)).coord,x_new,map) %%�ж���������ڵ���չ���½ڵ�·�����Ƿ����ϰ�����ײ
                continue; %��ִ��ѭ�������²��֣�ֱ�ӿ�ʼ�´�ѭ����������½ڵ����ϣ����¸�ֵ��������ǰ�β�������������
            end
            temp_Cost = Cost_InitToNew;
            temp_parent = Index_NearToNewList(i); %%�ڵ�������
        end
    end
    
    %step6����x_new���뵽�������
    counter = counter+1;
    RRTStarTree.node(counter).coord = x_new;
    RRTStarTree.node(counter).Parent = RRTStarTree.node(temp_parent).coord;
    RRTStarTree.node(counter).Cost = temp_Cost;
    RRTStarTree.node(counter).ParIndex = temp_parent;
    P_handle = plot(x_new(2), x_new(1), 'o', 'MarkerSize', 6, 'MarkerFaceColor','k');
    L_handle = plot([RRTStarTree.node(counter).Parent(2), x_new(2)], [RRTStarTree.node(counter).Parent(1), x_new(1)], 'g', 'Linewidth', 3);
    P_handleList = [P_handleList P_handle];
    L_handleList = [L_handleList L_handle];
    disp('����ѡ�񸸽ڵ����');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%���ˣ�RRT*�㷨�ĵ�һ���֣�����ѡ�񸸽ڵ㣩���̽���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   %step7:���²���
    for i = 1:length(Index_NearToNewList)
        if (Index_NearToNewList(i) ~= temp_parent) %%���ڵ㲻����qnear����
            Dis_NewToNear = temp_Cost + Dis_NearToNewList(i);
            if (Dis_NewToNear<RRTStarTree.node(Index_NearToNewList(i)).Cost) %%�������²�������
                NearPoint = RRTStarTree.node(Index_NearToNewList(i)).coord;
                if ~checkPath(NearPoint,x_new,map) %%�ж���������ڵ���չ���½ڵ�·�����Ƿ����ϰ�����ײ
                    continue; %��ִ��ѭ�������²��֣�ֱ�ӿ�ʼ�´�ѭ����������½ڵ����ϣ����¸�ֵ��������ǰ�β�������������
                end
                RRTStarTree.node(Index_NearToNewList(i)).Parent = x_new;     %%���¸��ڵ�
                RRTStarTree.node(Index_NearToNewList(i)).Cost = Dis_NewToNear;  %%���´���
                RRTStarTree.node(Index_NearToNewList(i)).ParIndex = counter;    %%x_new��������
                lHandleList(Index_NearToNewList(i)) = plot([RRTStarTree.node(Index_NearToNewList(i)).coord(2), x_new(2)], [RRTStarTree.node(Index_NearToNewList(i)).coord(1), x_new(1)], 'r', 'Linewidth', 3);%%�����滻����
            end
        end
    end
    %Step 8:���x_new�Ƿ񵽴�Ŀ��㸽�� 
    if (distanceCost(x_new,[x_goal y_goal]) < threshold && ~pathFound) %ֻ����һ�Σ�����ֻ������չ����δ̽�����ĵ�
        pathFound = 1;
        counter = counter + 1;
        Goal_Index = counter;
        RRTStarTree.node(counter).coord = [x_goal y_goal];
        RRTStarTree.node(counter).Partent = x_new;
        RRTStarTree.node(counter).ParIndex = counter-1;  %%Ŀ��ڵ�ĸ��ڵ��������
    end
    %step9:�ڹ涨����������Ѱ������·��
    if (pathFound == 1)
            disp('�ҵ�·��');
            path.pos(1).x = x_goal;
            path.pos(1).y = y_goal;
            pathIndex = RRTStarTree.node(Goal_Index).ParIndex;
            j =2;
            while 1
                path.pos(j).x = RRTStarTree.node(pathIndex).coord(1);
                path.pos(j).y = RRTStarTree.node(pathIndex).coord(2);
                pathIndex = RRTStarTree.node(pathIndex).ParIndex;
                if pathIndex ==0
                    break; %%�˳�����whileѭ��
                end
                j = j+1;
            end
            for delete_index = 1:length(resHandleList)
                delete(resHandleList(delete_index));
            end
            for j = 2:length(path.pos)
                res_handle = plot([path.pos(j).y; path.pos(j-1).y;], [path.pos(j).x; path.pos(j-1).x], 'b', 'Linewidth', 4);
                resHandleList = [resHandleList res_handle];
            end
    end
    pause(0.01)
end
toc;
title('2D RRTStar Algorithm');
