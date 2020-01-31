%  MATLAB Source Codes for the book "Cooperative Dedcision and Planning for
%  Connected and Automated Vehicles" published by Mechanical Industry Press
%  in 2020.
% ��������������Эͬ������滮�������鼮���״���
%  Copyright (C) 2020 Bai Li
%  2020.01.31
% ==============================================================================
%  �ڶ���. 2.4.4С��. S-Tͼ��A�������㷨ʵ���ٶȾ��ߣ���һ�ַǳ����Եľֲ��ٶȹ滮�������ֽ��
% ==============================================================================
%  ��ע��
%  1. st_graph_search_.penalty_for_inf_velocityȡֵ��ͬ�������ֳ�����ͨ����������еĲ��죬��������г���
%  2. �Ӷ�̬Ч������������ɢ�����µ�΢С���ڹ���ʵ���п�ͨ��������ײ�������������⣬���ٶȾ��߱���Ҳֻ��
%     ���Եļ��㣬�����Щ���Ҳ�޷�.
% ==============================================================================
close all
clc

% % ��������
global vehicle_geometrics_ % �����������γߴ�
vehicle_geometrics_.vehicle_wheelbase = 2.8;
vehicle_geometrics_.vehicle_front_hang = 0.96;
vehicle_geometrics_.vehicle_rear_hang = 0.929;
vehicle_geometrics_.vehicle_width = 1.942;
vehicle_geometrics_.vehicle_length = vehicle_geometrics_.vehicle_wheelbase + vehicle_geometrics_.vehicle_front_hang + vehicle_geometrics_.vehicle_rear_hang;
vehicle_geometrics_.radius = hypot(0.25 * vehicle_geometrics_.vehicle_length, 0.5 * vehicle_geometrics_.vehicle_width);
vehicle_geometrics_.r2x = 0.25 * vehicle_geometrics_.vehicle_length - vehicle_geometrics_.vehicle_rear_hang;
vehicle_geometrics_.f2x = 0.75 * vehicle_geometrics_.vehicle_length - vehicle_geometrics_.vehicle_rear_hang;
global vehicle_kinematics_ % �����˶���������
vehicle_kinematics_.vehicle_v_max = 2.5;
vehicle_kinematics_.vehicle_a_max = 0.5;
vehicle_kinematics_.vehicle_phy_max = 0.7;
vehicle_kinematics_.vehicle_w_max = 0.5;
vehicle_kinematics_.vehicle_kappa_max = tan(vehicle_kinematics_.vehicle_phy_max) / vehicle_geometrics_.vehicle_wheelbase;
vehicle_kinematics_.vehicle_turning_radius_min = 1 / vehicle_kinematics_.vehicle_kappa_max;
global environment_scale_ % �������ڻ�����Χ
environment_scale_.environment_x_min = -20;
environment_scale_.environment_x_max = 20;
environment_scale_.environment_y_min = -20;
environment_scale_.environment_y_max = 20;
environment_scale_.x_scale = environment_scale_.environment_x_max - environment_scale_.environment_x_min;
environment_scale_.y_scale = environment_scale_.environment_y_max - environment_scale_.environment_y_min;

% % ����S-Tͼ������A���㷨�漰�Ĳ���
global st_graph_search_
st_graph_search_.num_nodes_s = 80;
st_graph_search_.num_nodes_t = 100;
st_graph_search_.multiplier_H_for_A_star = 2.0;
st_graph_search_.penalty_for_inf_velocity = 4;

% % ����ȶ������Լ���ֹ�ϰ���ֲ����
global vehicle_TPBV_ obstacle_vertexes_
load TaskSetup.mat
[x, y, theta, path_length, completeness_flag] = ProvideCoarsePathViaHybridAStarSearch();
st_graph_search_.resolution_s = path_length / st_graph_search_.num_nodes_s;

% % �����ƶ��ϰ��ָ���˶�ʱ�򲢸����ƶ�������˶��켣
global dynamic_obs
st_graph_search_.max_t = round(path_length * 2);
st_graph_search_.max_s = path_length;
st_graph_search_.resolution_t = st_graph_search_.max_t / st_graph_search_.num_nodes_t;
dynamic_obs = GenerateDynamicObstacles();
for ii = 1 : size(dynamic_obs,1)
    for jj = 1 : size(dynamic_obs,2)
        obs = dynamic_obs{ii,jj};
        fill(obs.x, obs.y, [125, 125, 125] ./ 255);
    end
end
drawnow;

% % S-Tͼ�����Լ���̬Ч��
[t,s] = SearchVelocityInStGraph(x, y, theta);
DemonstrateDynamicResult(x, y, theta, t, s);