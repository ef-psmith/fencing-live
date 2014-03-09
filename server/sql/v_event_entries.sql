ALTER ALGORITHM=UNDEFINED DEFINER=`engarde`@`%` SQL SECURITY DEFINER 
VIEW `v_event_entries` AS select `e`.`id` AS `entry_id`,`e`.`event_id` AS `event_id`,
`e`.`presence` AS `presence`,`e`.`ranking` AS `ranking`,`e`.`points` AS `points`,`p`.`id` AS `id`,
`p`.`nom` AS `nom`,`p`.`prenom` AS `prenom`,`p`.`licence` AS `licence`,
`p`.`licence_fie` AS `licence_fie`,`p`.`dob` AS `dob`,`p`.`nation_id` AS `nation_id`, n.nom as nation, c.short_name as club, c.id as club_id,
`p`.`hand` AS `hand` from `entries` `e` left join `people` `p` on `e`.`person_id` = `p`.`id` left join clubs c on c.id = e.club_id
left join nations n on n.cle = p.nation_id;
