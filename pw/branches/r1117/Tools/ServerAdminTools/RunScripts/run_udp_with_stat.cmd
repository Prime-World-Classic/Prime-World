call 00UniServerApp-coordinator.cmd
call 14UniServerApp-clientctrl.cmd
call 03UniServerApp-chat.cmd
call 05UniServerApp-lobby.cmd
call 06UniServerApp-gamesvc.cmd
call 07UniServerApp-gamebalancer.cmd
call 10UniServerApp-monitoring.cmd
call 11UniServerApp-clusteradmin.cmd
call 12UniServerApp-roll.cmd
call 13UniServerApp-rollbalancer.cmd
call stat-pvx-start.cmd
call wait 3
call stat-social-start.cmd
call wait 6
call monitoring-start.cmd
call 20UniServerApp-newlogin.cmd
