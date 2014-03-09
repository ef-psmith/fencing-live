-- phpMyAdmin SQL Dump
-- version 4.0.4
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Aug 19, 2013 at 03:35 PM
-- Server version: 5.00.15
-- PHP Version: 5.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: 'engarde'
--
CREATE DATABASE IF NOT EXISTS engarde DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE engarde;

-- --------------------------------------------------------

--
-- Table structure for table 'competitions'
--

DROP TABLE IF EXISTS competitions;
CREATE TABLE IF NOT EXISTS competitions (
  id int(11) NOT NULL AUTO_INCREMENT,
  event_id int(11) NOT NULL,
  title_full varchar(80) NOT NULL,
  title_short varchar(40) DEFAULT NULL,
  weapon enum('F','E','S') NOT NULL,
  PRIMARY KEY (id),
  KEY event_id (event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table 'events'
--

DROP TABLE IF EXISTS events;
CREATE TABLE IF NOT EXISTS `events` (
  id int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table 'people'
--

DROP TABLE IF EXISTS people;
CREATE TABLE IF NOT EXISTS people (
  id int(11) NOT NULL AUTO_INCREMENT,
  surname varchar(60) NOT NULL,
  forename varchar(60) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table competitions
--
ALTER TABLE competitions
  ADD CONSTRAINT competitions_ibfk_1 FOREIGN KEY (event_id) REFERENCES `events` (id) ON DELETE CASCADE ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
