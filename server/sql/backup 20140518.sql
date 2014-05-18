-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.32 - MySQL Community Server (GPL)
-- Server OS:                    Win32
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table engarde.clubs
DROP TABLE IF EXISTS `clubs`;
CREATE TABLE IF NOT EXISTS `clubs` (
  `event_id` int(11) NOT NULL,
  `cle` int(11) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `nom_court` varchar(20) DEFAULT NULL,
  `nation1` int(11) DEFAULT NULL,
  PRIMARY KEY (`event_id`,`cle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table engarde.clubs: ~0 rows (approximately)
/*!40000 ALTER TABLE `clubs` DISABLE KEYS */;
/*!40000 ALTER TABLE `clubs` ENABLE KEYS */;


-- Dumping structure for table engarde.control
DROP TABLE IF EXISTS `control`;
CREATE TABLE IF NOT EXISTS `control` (
  `config_key` varchar(30) NOT NULL,
  `config_value` varchar(255) NOT NULL,
  PRIMARY KEY (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table engarde.control: ~10 rows (approximately)
/*!40000 ALTER TABLE `control` DISABLE KEYS */;
REPLACE INTO `control` (`config_key`, `config_value`) VALUES
	('allowunpaid', 'false'),
	('checkintimeout', '100000'),
	('debug', '1'),
	('log', './out.txt'),
	('nif', 'false'),
	('restrictIP', 'false'),
	('statusTimeout', '40000'),
	('targetlocation', '/home/engarde/live/web'),
	('title', 'DB Admin Portal'),
	('tournamentname', 'Test Events 2014');
/*!40000 ALTER TABLE `control` ENABLE KEYS */;


-- Dumping structure for table engarde.entries
DROP TABLE IF EXISTS `entries`;
CREATE TABLE IF NOT EXISTS `entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `club1` int(11) DEFAULT NULL,
  `presence` enum('present','absent','scratched') NOT NULL DEFAULT 'absent',
  `ranking` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `paiement` decimal(10,2) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_id` (`event_id`,`person_id`),
  KEY `event_id_2` (`event_id`,`ranking`)
) ENGINE=InnoDB AUTO_INCREMENT=433 DEFAULT CHARSET=utf8;

-- Dumping data for table engarde.entries: ~0 rows (approximately)
/*!40000 ALTER TABLE `entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `entries` ENABLE KEYS */;


-- Dumping structure for table engarde.events
DROP TABLE IF EXISTS `events`;
CREATE TABLE IF NOT EXISTS `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titre_ligne` varchar(80) DEFAULT NULL,
  `background` varchar(20) DEFAULT NULL,
  `nif` tinyint(4) DEFAULT NULL,
  `source` varchar(128) DEFAULT NULL,
  `state` varchar(20) DEFAULT NULL,
  `enabled` enum('true','false') NOT NULL DEFAULT 'true',
  `message` varchar(255) DEFAULT NULL,
  `hold` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

-- Dumping data for table engarde.events: ~0 rows (approximately)
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
/*!40000 ALTER TABLE `events` ENABLE KEYS */;


-- Dumping structure for table engarde.nations
DROP TABLE IF EXISTS `nations`;
CREATE TABLE IF NOT EXISTS `nations` (
  `event_id` int(11) NOT NULL,
  `cle` int(11) NOT NULL,
  `nom` char(3) NOT NULL,
  `nom_etendu` varchar(50) NOT NULL,
  PRIMARY KEY (`event_id`,`cle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table engarde.nations: ~0 rows (approximately)
/*!40000 ALTER TABLE `nations` DISABLE KEYS */;
/*!40000 ALTER TABLE `nations` ENABLE KEYS */;


-- Dumping structure for table engarde.people
DROP TABLE IF EXISTS `people`;
CREATE TABLE IF NOT EXISTS `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(60) NOT NULL,
  `prenom` varchar(60) NOT NULL,
  `licence` int(11) DEFAULT NULL,
  `licence_fie` char(14) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `nation1` int(11) DEFAULT NULL,
  `hand` char(1) DEFAULT NULL,
  `expires` date DEFAULT NULL,
  `sexe` enum('m','f') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `licence` (`licence`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table engarde.people: ~0 rows (approximately)
/*!40000 ALTER TABLE `people` DISABLE KEYS */;
/*!40000 ALTER TABLE `people` ENABLE KEYS */;


-- Dumping structure for table engarde.series
DROP TABLE IF EXISTS `series`;
CREATE TABLE IF NOT EXISTS `series` (
  `comp_id` int(11) NOT NULL,
  `series_mask` int(11) NOT NULL,
  PRIMARY KEY (`comp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table engarde.series: ~0 rows (approximately)
/*!40000 ALTER TABLE `series` DISABLE KEYS */;
/*!40000 ALTER TABLE `series` ENABLE KEYS */;


-- Dumping structure for view engarde.v_event_entries
DROP VIEW IF EXISTS `v_event_entries`;
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `v_event_entries` (
	`entry_id` INT(11) NOT NULL,
	`event_id` INT(11) NOT NULL,
	`presence` ENUM('present','absent','scratched') NOT NULL COLLATE 'utf8_general_ci',
	`ranking` INT(11) NULL,
	`points` INT(11) NULL,
	`id` INT(11) NULL,
	`nom` VARCHAR(60) NULL COLLATE 'utf8_general_ci',
	`prenom` VARCHAR(60) NULL COLLATE 'utf8_general_ci',
	`licence` INT(11) NULL,
	`licence_fie` CHAR(14) NULL COLLATE 'utf8_general_ci',
	`dob` DATE NULL,
	`nation_id` INT(11) NULL,
	`nation` CHAR(3) NULL COLLATE 'utf8_general_ci',
	`club` VARCHAR(50) NULL COLLATE 'utf8_general_ci',
	`club_id` INT(11) NULL,
	`paiement` DECIMAL(10,2) NULL
) ENGINE=MyISAM;


-- Dumping structure for trigger engarde.events_before_delete
DROP TRIGGER IF EXISTS `events_before_delete`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `events_before_delete` BEFORE DELETE ON `events` FOR EACH ROW BEGIN
delete from clubs where event_id = OLD.id;
delete from nations where event_id = OLD.id;
delete from entries where event_id = OLD.id;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping structure for view engarde.v_event_entries
DROP VIEW IF EXISTS `v_event_entries`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `v_event_entries`;
CREATE ALGORITHM=UNDEFINED DEFINER=`engarde`@`%` SQL SECURITY DEFINER VIEW `v_event_entries` AS select `e`.`id` AS `entry_id`,`e`.`event_id` AS `event_id`,`e`.`presence` AS `presence`,`e`.`ranking` AS `ranking`,`e`.`points` AS `points`,`p`.`id` AS `id`,`p`.`nom` AS `nom`,`p`.`prenom` AS `prenom`,`p`.`licence` AS `licence`,`p`.`licence_fie` AS `licence_fie`,`p`.`dob` AS `dob`,`p`.`nation1` AS `nation_id`,`n`.`nom` AS `nation`,`c`.`nom` AS `club`,`c`.`cle` AS `club_id`,`e`.`paiement` AS `paiement` from (((`entries` `e` left join `people` `p` on((`e`.`person_id` = `p`.`id`))) left join `clubs` `c` on(((`c`.`event_id` = `e`.`event_id`) and (`c`.`cle` = `e`.`club1`)))) left join `nations` `n` on(((`n`.`event_id` = `e`.`event_id`) and (`n`.`cle` = `p`.`nation1`))));
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
