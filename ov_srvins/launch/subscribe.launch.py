from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, LogInfo, OpaqueFunction, IncludeLaunchDescription, ExecuteProcess, TimerAction
from launch.conditions import IfCondition
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution, FindExecutable
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare
from ament_index_python.packages import get_package_share_directory
import os


launch_args = [
    DeclareLaunchArgument(
        name="namespace", default_value="ov_srvins", description="namespace"
    ),
    DeclareLaunchArgument(
        name="ov_enable", default_value="true", description="enable SRVINS node"
    ),
    DeclareLaunchArgument(
        name="foxglove_enable", default_value="false", description="enable Foxglove node"
    ),
    DeclareLaunchArgument(
        name="config",
        default_value="euroc_mav",
        description="euroc_mav, tum_vi, rpng_aruco...",
    ),
    DeclareLaunchArgument(
        name="config_path",
        default_value="",
        description="path to estimator_config.yaml. If not given, determined based on provided 'config' above",
    ),
    DeclareLaunchArgument(
        name="verbosity",
        default_value="INFO",
        description="ALL, DEBUG, INFO, WARNING, ERROR, SILENT",
    ),
    DeclareLaunchArgument(
        name="use_stereo",
        default_value="true",
        description="if we have more than 1 camera, if we should try to track stereo constraints between pairs",
    ),
    DeclareLaunchArgument(
        name="max_cameras",
        default_value="2",
        description="how many cameras we have 1 = mono, 2 = stereo, >2 = binocular (all mono tracking)",
    ),
    DeclareLaunchArgument(
        name="save_total_state",
        default_value="false",
        description="record the total state with calibration and features to a txt file",
    ),
    DeclareLaunchArgument(
        name="use_bag", default_value="false", description="enable ROS bag playing"
    ),
    DeclareLaunchArgument(
        name="bag", default_value="", description="ROS bag to play"
    ),
    DeclareLaunchArgument(
        name="skip_sec", default_value="0", description="Skip N seconds when playing ROS bag file"
    ),
]


def launch_setup(context):
    config_path = LaunchConfiguration("config_path").perform(context)
    if not config_path:
        configs_dir = os.path.join(get_package_share_directory("ov_srvins"), "config")
        available_configs = os.listdir(configs_dir)
        config = LaunchConfiguration("config").perform(context)
        if config in available_configs:
            config_path = os.path.join(
                get_package_share_directory("ov_srvins"),
                "config",
                config,
                "estimator_config.yaml",
            )
        else:
            return [
                LogInfo(
                    msg="ERROR: unknown config: '{}' - Available configs are: {} - not starting OpenVINS".format(
                        config, ", ".join(available_configs)
                    )
                )
            ]
    else:
        if not os.path.isfile(config_path):
            return [
                LogInfo(
                    msg="ERROR: config_path file: '{}' - does not exist. - not starting OpenVINS".format(
                        config_path
                    )
                )
            ]

    # Foxglove node
    foxglove_node = IncludeLaunchDescription(
        PathJoinSubstitution([FindPackageShare('ov_srvins'), 'launch', 'foxglove_bridge.launch.py']),
        condition=IfCondition(LaunchConfiguration('foxglove_enable'))
    )

    # Master node
    master_node = Node(
        package="ov_srvins",
        executable="run_subscribe_msckf",
        condition=IfCondition(LaunchConfiguration("ov_enable")),
        namespace=LaunchConfiguration("namespace"),
        output="screen",
        parameters=[
            {"verbosity": LaunchConfiguration("verbosity")},
            {"use_stereo": LaunchConfiguration("use_stereo")},
            {"max_cameras": LaunchConfiguration("max_cameras")},
            {"save_total_state": LaunchConfiguration("save_total_state")},
            {"config_path": config_path},
        ],
    )

    # Play ROS bag (wait a few seconds for SLAM node to fully initialized)
    bag_node = TimerAction(
        period=3.0,
        actions=[
            ExecuteProcess(
                cmd=[[
                    FindExecutable(name='ros2'),
                    ' bag play --disable-keyboard-controls --start-offset ',
                    LaunchConfiguration('skip_sec'), ' ',
                    LaunchConfiguration('bag')
                ]],
                shell=True
            )
        ],
        condition=IfCondition(LaunchConfiguration("use_bag"))
    )

    return [foxglove_node, master_node, bag_node]


def generate_launch_description():
    opfunc = OpaqueFunction(function=launch_setup)
    ld = LaunchDescription(launch_args)
    ld.add_action(opfunc)
    return ld
