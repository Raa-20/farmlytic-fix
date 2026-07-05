-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 26, 2026 at 03:43 AM
-- Server version: 8.0.30
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `farmlytics`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `ID_ADMIN` int NOT NULL,
  `NAMA` varchar(255) DEFAULT NULL,
  `USERNAME` varchar(100) DEFAULT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `NO_HP` varchar(20) DEFAULT NULL,
  `foto` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`ID_ADMIN`, `NAMA`, `USERNAME`, `PASSWORD`, `EMAIL`, `NO_HP`, `foto`) VALUES
(1, 'Admin', 'admin', 'scrypt:32768:8:1$Udwt0FN1F3xkeGhz$4fb1820d2a50350cb633c8719a0ac7d6a67e2e08ac07b6e2780a7f67b35db35124b17e71291620708a9075ff3a61bb567116baac049a39f936729403224dd69c', NULL, NULL, ''),
(2, 'admin2', 'admin2', 'scrypt:32768:8:1$sAKDsrjOslE1JF7S$29ccc524d7fd581497790ecd830a381bbf3a47eb356fb482dbe37100bff152858021212b5cb891412504e8e19d1a5a290373e03238f13c6f936bad8667c9fa3d', 'admin@gmail.com', '082133332222', '');

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `ID_AUDIT_LOG` int NOT NULL,
  `ID_ADMIN` int DEFAULT NULL,
  `ID_DINAS` int DEFAULT NULL,
  `ID_SUPERVISOR` int DEFAULT NULL,
  `ID_PETUGAS_BANGSAL` int DEFAULT NULL,
  `USER_TYPE` varchar(50) DEFAULT NULL,
  `AKTIVITAS` varchar(255) DEFAULT NULL,
  `DETAIL_INPUT` text,
  `TANGGAL` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `audit_log`
--

INSERT INTO `audit_log` (`ID_AUDIT_LOG`, `ID_ADMIN`, `ID_DINAS`, `ID_SUPERVISOR`, `ID_PETUGAS_BANGSAL`, `USER_TYPE`, `AKTIVITAS`, `DETAIL_INPUT`, `TANGGAL`) VALUES
(1, 1, NULL, NULL, NULL, 'admin', 'Login', 'Admin login', '2026-05-01 15:23:23'),
(2, 1, NULL, NULL, NULL, 'admin', 'Input Panen', 'Menambahkan data panen', '2026-05-01 15:23:23'),
(3, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk tomat dengan berat 7 Kg di lokasi kilo lokasi Desa trosono Kecamatan Parang Kabupaten Magetan Jawa Timur gagal panen', '2026-06-24 07:01:46'),
(4, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk cabai dengan berat 5 Kg di lokasi di desa balegondo Kecamatan ngariboyo Kabupaten Magetan Jawa Timur gagal panen', '2026-06-24 07:40:06'),
(5, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk tomat dengan berat 20 Kg di lokasi lokasi Desa Jeruk gagal panen', '2026-06-24 09:00:57'),
(6, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk tomat dengan berat 3 Kg di lokasi di desa Jaya gagal panen', '2026-06-24 09:07:43'),
(7, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk kentang dengan berat 7 Kg di lokasi Gagal Panen', '2026-06-24 09:13:39'),
(8, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk cabai dengan berat 100 Kg di lokasi Desa Makmur', '2026-06-24 09:15:14'),
(9, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk jagung dengan berat 10 Kg di lokasi Desa Sukajaya', '2026-06-24 09:17:01'),
(10, NULL, NULL, NULL, NULL, 'Petugas', 'Input Data Voice', 'Menambahkan data masuk jagung dengan berat 200 Kg di lokasi Desa Batu', '2026-06-24 09:22:24'),
(11, NULL, NULL, NULL, NULL, 'Petugas', 'Hapus Data', 'Menghapus data transaksi TRX-24 (tomat)', '2026-06-25 14:37:00'),
(12, NULL, NULL, NULL, NULL, 'Petugas', 'Login', 'User a berhasil masuk ke sistem', '2026-06-25 14:53:19'),
(13, NULL, NULL, NULL, NULL, 'Dinas', 'Login', 'User dinas berhasil masuk ke sistem', '2026-06-25 14:54:00'),
(14, NULL, NULL, NULL, NULL, 'Petugas', 'Login', 'User a berhasil masuk ke sistem', '2026-06-25 14:54:36'),
(15, NULL, NULL, NULL, NULL, 'Petugas', 'Edit Data', 'Komoditas: Cabai -> Cabai\nBerat: 30.0 Kg -> 30.0 Kg\nLokasi: Desa Trosono, -> Desa Trosono,\nGagal Panen: 2 -> 2\nGrade: A -> B\nTanggal: 2026-04-10 -> 2026-04-10\nJenis Transaksi: masuk -> masuk\nFoto: - -> 1000477360.jpg', '2026-06-25 14:54:58'),
(16, NULL, NULL, NULL, NULL, 'Petugas', 'Login', 'User a berhasil masuk ke sistem', '2026-06-26 02:09:24'),
(17, NULL, NULL, NULL, NULL, 'Admin', 'Login', 'User admin berhasil masuk ke sistem', '2026-06-26 02:15:30'),
(18, NULL, NULL, NULL, NULL, 'Admin', 'Login', 'User admin berhasil masuk ke sistem', '2026-06-26 02:15:49'),
(19, NULL, NULL, NULL, NULL, 'Petugas', 'Login', 'User a berhasil masuk ke sistem', '2026-06-26 02:17:03'),
(20, NULL, NULL, NULL, NULL, 'Admin', 'Login', 'User admin berhasil masuk ke sistem', '2026-06-26 02:19:03'),
(21, NULL, NULL, NULL, NULL, 'Admin', 'Login', 'User admin berhasil masuk ke sistem', '2026-06-26 02:21:14'),
(22, NULL, NULL, NULL, NULL, 'Admin', 'Login', 'User admin berhasil masuk ke sistem', '2026-06-26 02:23:33'),
(23, NULL, NULL, NULL, NULL, 'Admin', 'Login', 'User admin berhasil masuk ke sistem', '2026-06-26 02:25:52'),
(24, NULL, NULL, NULL, NULL, 'Admin', 'Login', 'User admin berhasil masuk ke sistem', '2026-06-26 02:34:59'),
(25, NULL, NULL, NULL, NULL, 'Dinas', 'Login', 'User dinas berhasil masuk ke sistem', '2026-06-26 02:36:23');

-- --------------------------------------------------------

--
-- Table structure for table `detail_panen`
--

CREATE TABLE `detail_panen` (
  `ID_DETAIL_PANEN` int NOT NULL,
  `ID_PANEN` int DEFAULT NULL,
  `GRADE` varchar(1) DEFAULT NULL,
  `BERAT` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `detail_panen`
--

INSERT INTO `detail_panen` (`ID_DETAIL_PANEN`, `ID_PANEN`, `GRADE`, `BERAT`) VALUES
(1, 1, 'A', '60.50'),
(2, 1, 'B', '40.00'),
(3, 2, 'A', '50.00'),
(4, 2, 'C', '25.00');

-- --------------------------------------------------------

--
-- Table structure for table `dinas`
--

CREATE TABLE `dinas` (
  `ID_DINAS` int NOT NULL,
  `NAMA_INSTANSI` varchar(255) DEFAULT NULL,
  `USERNAME` varchar(100) DEFAULT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `EMAIL` varchar(255) DEFAULT NULL,
  `NO_HP` varchar(15) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `dinas`
--

INSERT INTO `dinas` (`ID_DINAS`, `NAMA_INSTANSI`, `USERNAME`, `PASSWORD`, `EMAIL`, `NO_HP`, `foto`) VALUES
(1, 'Dinas Pertanian', 'd', '1', NULL, NULL, NULL),
(2, 'dinas', 'dinas', 'scrypt:32768:8:1$YtDjY5I3KvYKtz3x$6ad218e20a015c87d0c8f9f97988778ffefeee6e49cf3154f5fc802f715fbc4dc44ddfb65530d416bff36458d4aa87b1e81be6348e3ff64db64072baa545cf70', 'dinas@gmail.com', '', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `hasil_panen`
--

CREATE TABLE `hasil_panen` (
  `ID_PANEN` int NOT NULL,
  `ID_PETUGAS_BANGSAL` int DEFAULT NULL,
  `ID_KOMODITAS` int DEFAULT NULL,
  `ID_SUPPLIER` int DEFAULT NULL,
  `TANGGAL` date DEFAULT NULL,
  `BERAT` decimal(10,2) DEFAULT NULL,
  `METODE_INPUT` varchar(50) DEFAULT NULL,
  `STATUS_VALIDASI` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `hasil_panen`
--

INSERT INTO `hasil_panen` (`ID_PANEN`, `ID_PETUGAS_BANGSAL`, `ID_KOMODITAS`, `ID_SUPPLIER`, `TANGGAL`, `BERAT`, `METODE_INPUT`, `STATUS_VALIDASI`) VALUES
(1, 1, 1, 1, '2026-05-01', '100.50', 'manual', 'pending'),
(2, 2, 2, 2, '2026-05-02', '75.00', 'voice', 'valid');

-- --------------------------------------------------------

--
-- Table structure for table `input_data`
--

CREATE TABLE `input_data` (
  `id` int NOT NULL,
  `komoditas` varchar(100) DEFAULT NULL,
  `berat` float DEFAULT NULL,
  `lokasi` varchar(150) DEFAULT NULL,
  `gagal` int DEFAULT NULL,
  `grade` enum('A','B','C') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `cara_input` varchar(20) DEFAULT 'manual',
  `tanggal` date DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `satuan` varchar(50) DEFAULT 'kg',
  `jenis_transaksi` varchar(20) DEFAULT 'masuk'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `input_data`
--

INSERT INTO `input_data` (`id`, `komoditas`, `berat`, `lokasi`, `gagal`, `grade`, `created_at`, `cara_input`, `tanggal`, `foto`, `satuan`, `jenis_transaksi`) VALUES
(1, 'Tomat', 50, 'Magetan', 2, 'A', '2026-05-01 15:23:23', 'voice', '2026-05-01', '1000451607.jpg', 'kg', 'masuk'),
(3, 'kentang ', 20, 'Zona Timur', 30, 'B', '2026-05-02 01:51:44', 'manual', '2026-05-02', '1000451608.jpg', 'kg', 'masuk'),
(4, 'Cabai', 10, 'Zona Timur', 11, 'B', '2026-05-02 02:20:53', 'manual', '2026-05-02', '1000451523.jpg', 'kg', 'masuk'),
(7, 'Jagung', 100, 'Jatim', 4, 'A', '2026-05-02 06:10:54', 'manual', '2026-04-23', '1000451067.jpg', 'kg', 'masuk'),
(10, 'cabai', 20, 'Zona Timur', 7, 'A', '2026-05-03 07:20:20', 'voice', '2026-04-14', '1000451607.jpg', 'kg', 'masuk'),
(11, 'Kentang', 70, 'Zona Timur', 20, 'A', '2026-05-03 22:03:24', 'manual', '2026-05-04', 'Screenshot_2026-04-29-07-36-39-16.jpg', 'kg', 'masuk'),
(12, 'cabai', 20, 'zona Timur', 3, 'B', '2026-05-03 22:05:26', 'voice', '2026-04-15', 'Screenshot_2026-04-29-07-36-39-16.jpg', 'kg', 'masuk'),
(13, 'Tomat', 10, 'pasar Magetan', 0, 'A', '2026-05-16 05:19:46', 'manual', '2026-05-15', '1000457021.jpg', 'Kg', 'keluar'),
(15, 'Cabai', 50, 'Kebun selatan', 5, 'B', '2026-06-22 14:09:24', 'wa_ai', '2026-06-22', NULL, 'Kg', 'masuk'),
(16, 'Cabai', 500, 'Provinsi Jawa Timur, Kabupaten Magetan, Kecamatan Plaosan, Desa Plaosan, Gagal Panen 5 Persen, Grade B', 5, 'B', '2026-06-22 15:18:29', 'wa_ai', '2026-06-22', NULL, 'Kg', 'masuk'),
(17, 'Tomat', 300, 'Pasar Induk', 0, 'A', '2026-06-24 06:14:27', 'wa_ai', '2024-08-12', NULL, 'Kg', 'keluar'),
(18, 'Tomat', 15, 'Pasar Magetan', 0, 'A', '2026-06-24 06:22:36', 'wa_ai', '2026-06-24', NULL, 'Kg', 'keluar'),
(19, 'Cabai', 50, 'Di Desa Plaosan, Kecamatan Plaosan, Kab Magetan, Jawa Timur', 5, 'A', '2026-06-24 06:35:03', 'wa_ai', '2024-08-12', NULL, 'Kg', 'masuk'),
(20, 'Jagung', 50, 'Di Desa Plaosan, Kecamatan Plaosan, Kabupaten Magetan, Jawa Timur', 5, 'A', '2026-06-24 06:40:25', 'wa_ai', '2026-08-12', NULL, 'Kg', 'masuk'),
(21, 'tomat', 7, 'kilo lokasi Desa trosono Kecamatan Parang Kabupaten Magetan Jawa Timur gagal panen', 3, NULL, '2026-06-24 00:01:46', 'voice', '2026-06-24', '', 'Kg', 'masuk'),
(25, 'kentang', 7, 'Gagal Panen', 5, 'A', '2026-06-24 02:13:39', 'voice', '2026-06-24', '', 'Kg', 'masuk'),
(26, 'cabai', 100, 'Desa Makmur', 6, 'B', '2026-06-24 02:15:14', 'voice', '2026-06-24', '', 'Kg', 'masuk'),
(27, 'jagung', 10, 'Desa Sukajaya', 6, 'A', '2026-06-24 02:17:01', 'voice', '2026-06-24', '', 'Kg', 'masuk'),
(28, 'jagung', 200, 'Desa Batu', 3, 'A', '2026-06-24 02:22:24', 'voice', '2026-05-23', '', 'Kg', 'masuk'),
(29, 'Cabai', 50, 'Desa Plaosan', 5, 'A', '2026-06-24 13:07:16', 'wa_ai', '2026-06-24', NULL, 'Kg', 'masuk'),
(30, 'Tomat', 50, 'Desa Plaosan', 5, 'B', '2026-06-24 15:48:33', 'wa_ai', '2026-04-12', NULL, 'Kg', 'masuk'),
(31, 'Cabai', 30, 'Desa Trosono,', 2, 'B', '2026-06-25 14:11:10', 'wa_ai', '2026-04-10', '1000477360.jpg', 'Kg', 'masuk');

-- --------------------------------------------------------

--
-- Table structure for table `insight`
--

CREATE TABLE `insight` (
  `ID_INSIGHT` int NOT NULL,
  `ID_LAPORAN` int DEFAULT NULL,
  `ANALISIS_MUTU` text,
  `ANALISIS_REJECT` text,
  `REKOMENDASI` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `insight`
--

INSERT INTO `insight` (`ID_INSIGHT`, `ID_LAPORAN`, `ANALISIS_MUTU`, `ANALISIS_REJECT`, `REKOMENDASI`) VALUES
(1, 1, 'Mutu baik', 'Sedikit reject', 'Pertahankan kualitas'),
(2, 2, 'Mutu cukup', 'Reject meningkat', 'Perbaiki sortasi');

-- --------------------------------------------------------

--
-- Table structure for table `komoditas`
--

CREATE TABLE `komoditas` (
  `ID_KOMODITAS` int NOT NULL,
  `NAMA_KOMODITAS` varchar(255) DEFAULT NULL,
  `JENIS_SAYUR` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `komoditas`
--

INSERT INTO `komoditas` (`ID_KOMODITAS`, `NAMA_KOMODITAS`, `JENIS_SAYUR`) VALUES
(1, 'Tomat', 'Sayur Buah'),
(2, 'Cabai', 'Sayur Buah'),
(3, 'Kubis', 'Sayur Daun');

-- --------------------------------------------------------

--
-- Table structure for table `laporan`
--

CREATE TABLE `laporan` (
  `ID_LAPORAN` int NOT NULL,
  `ID_LOKASI` int DEFAULT NULL,
  `JENIS_LAPORAN` varchar(100) DEFAULT NULL,
  `TANGGAL` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `laporan`
--

INSERT INTO `laporan` (`ID_LAPORAN`, `ID_LOKASI`, `JENIS_LAPORAN`, `TANGGAL`) VALUES
(1, 1, 'Harian', '2026-05-01'),
(2, 2, 'Harian', '2026-05-02');

-- --------------------------------------------------------

--
-- Table structure for table `lokasi`
--

CREATE TABLE `lokasi` (
  `ID_LOKASI` int NOT NULL,
  `ALAMAT` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `lokasi`
--

INSERT INTO `lokasi` (`ID_LOKASI`, `ALAMAT`) VALUES
(1, 'Magetan'),
(2, 'Madiun');

-- --------------------------------------------------------

--
-- Table structure for table `petugas_bangsal`
--

CREATE TABLE `petugas_bangsal` (
  `ID_PETUGAS_BANGSAL` int NOT NULL,
  `ID_LOKASI` int DEFAULT NULL,
  `EMAIL` varchar(255) NOT NULL,
  `USERNAME` varchar(100) DEFAULT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `petugas_bangsal`
--

INSERT INTO `petugas_bangsal` (`ID_PETUGAS_BANGSAL`, `ID_LOKASI`, `EMAIL`, `USERNAME`, `PASSWORD`, `no_hp`, `foto`) VALUES
(1, 1, 'petugas1@mail.com', 'petugas1', 'scrypt:32768:8:1$gAKz1YyNw0asF6Zc$1b1719d1728e7d8b87345f57306b9f641b7d67085ede48de8feb91de999e0c97aa9339800ab63bff2363a735023e438f44b0dbe0366d37ef8be1ffe0afff86ad', '08111', ''),
(2, 2, 'petugas2@mail.com', 'petugas2', '123456', '0822222222', 'uploads/petugas2.jpg'),
(3, 2, 'asep@gmail.com', 'a', 'scrypt:32768:8:1$tU4HCfAPSIk00wvj$f22e0195ae4b0a91a19934f3536bad23d72e891ca960effd10008fab2af1d2dc55cf34a267c252ee07fc250367395a1cf4de1be1d19754350db7e43ff0ae0cb8', '0857779632581', 'Petugas_a.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `reject_panen`
--

CREATE TABLE `reject_panen` (
  `ID_REJECT` int NOT NULL,
  `ID_PANEN` int DEFAULT NULL,
  `JUMLAH_REJECT` decimal(10,2) DEFAULT NULL,
  `PENYEBAB` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `reject_panen`
--

INSERT INTO `reject_panen` (`ID_REJECT`, `ID_PANEN`, `JUMLAH_REJECT`, `PENYEBAB`) VALUES
(1, 1, '5.00', 'Busuk'),
(2, 2, '3.00', 'Kecil');

-- --------------------------------------------------------

--
-- Table structure for table `supervisor`
--

CREATE TABLE `supervisor` (
  `ID_SUPERVISOR` int NOT NULL,
  `ID_LOKASI` int DEFAULT NULL,
  `NAMA` varchar(255) DEFAULT NULL,
  `USERNAME` varchar(100) DEFAULT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `EMAIL` varchar(255) DEFAULT NULL,
  `NO_HP` varchar(15) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `supervisor`
--

INSERT INTO `supervisor` (`ID_SUPERVISOR`, `ID_LOKASI`, `NAMA`, `USERNAME`, `PASSWORD`, `EMAIL`, `NO_HP`, `foto`) VALUES
(1, 1, 'Supervisor A', 'super1', 'scrypt:32768:8:1$hRq2fF0Fd6KBls5C$e51432543cbe6f4fb979066084999d637af8264a8e75e3b6d49dd7ed113b028e6181d52d74e31f5bf7add0b2279d2edbd177a60da4f0f21e5970a44be0975e9a', NULL, NULL, 'Supervisor_super1.jpg'),
(2, 2, 'Supervisor B', 'super2', '123456', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `ID_SUPPLIER` int NOT NULL,
  `NAMA_SUPPLIER` varchar(255) DEFAULT NULL,
  `KONTAK` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`ID_SUPPLIER`, `NAMA_SUPPLIER`, `KONTAK`) VALUES
(1, 'Pak Budi', '081234567890'),
(2, 'Bu Siti', '081298765432');

-- --------------------------------------------------------

--
-- Table structure for table `validasi`
--

CREATE TABLE `validasi` (
  `ID_VALIDASI` int NOT NULL,
  `ID_PANEN` int DEFAULT NULL,
  `STATUS_VALIDASI` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `validasi`
--

INSERT INTO `validasi` (`ID_VALIDASI`, `ID_PANEN`, `STATUS_VALIDASI`) VALUES
(1, 1, 'pending'),
(2, 2, 'valid');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`ID_ADMIN`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`ID_AUDIT_LOG`),
  ADD KEY `ID_ADMIN` (`ID_ADMIN`),
  ADD KEY `ID_DINAS` (`ID_DINAS`),
  ADD KEY `ID_SUPERVISOR` (`ID_SUPERVISOR`),
  ADD KEY `ID_PETUGAS_BANGSAL` (`ID_PETUGAS_BANGSAL`);

--
-- Indexes for table `detail_panen`
--
ALTER TABLE `detail_panen`
  ADD PRIMARY KEY (`ID_DETAIL_PANEN`),
  ADD KEY `ID_PANEN` (`ID_PANEN`);

--
-- Indexes for table `dinas`
--
ALTER TABLE `dinas`
  ADD PRIMARY KEY (`ID_DINAS`);

--
-- Indexes for table `hasil_panen`
--
ALTER TABLE `hasil_panen`
  ADD PRIMARY KEY (`ID_PANEN`),
  ADD KEY `ID_PETUGAS_BANGSAL` (`ID_PETUGAS_BANGSAL`),
  ADD KEY `ID_KOMODITAS` (`ID_KOMODITAS`),
  ADD KEY `ID_SUPPLIER` (`ID_SUPPLIER`);

--
-- Indexes for table `input_data`
--
ALTER TABLE `input_data`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `insight`
--
ALTER TABLE `insight`
  ADD PRIMARY KEY (`ID_INSIGHT`),
  ADD KEY `ID_LAPORAN` (`ID_LAPORAN`);

--
-- Indexes for table `komoditas`
--
ALTER TABLE `komoditas`
  ADD PRIMARY KEY (`ID_KOMODITAS`);

--
-- Indexes for table `laporan`
--
ALTER TABLE `laporan`
  ADD PRIMARY KEY (`ID_LAPORAN`),
  ADD KEY `ID_LOKASI` (`ID_LOKASI`);

--
-- Indexes for table `lokasi`
--
ALTER TABLE `lokasi`
  ADD PRIMARY KEY (`ID_LOKASI`);

--
-- Indexes for table `petugas_bangsal`
--
ALTER TABLE `petugas_bangsal`
  ADD PRIMARY KEY (`ID_PETUGAS_BANGSAL`),
  ADD KEY `ID_LOKASI` (`ID_LOKASI`);

--
-- Indexes for table `reject_panen`
--
ALTER TABLE `reject_panen`
  ADD PRIMARY KEY (`ID_REJECT`),
  ADD KEY `ID_PANEN` (`ID_PANEN`);

--
-- Indexes for table `supervisor`
--
ALTER TABLE `supervisor`
  ADD PRIMARY KEY (`ID_SUPERVISOR`),
  ADD KEY `ID_LOKASI` (`ID_LOKASI`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`ID_SUPPLIER`);

--
-- Indexes for table `validasi`
--
ALTER TABLE `validasi`
  ADD PRIMARY KEY (`ID_VALIDASI`),
  ADD KEY `ID_PANEN` (`ID_PANEN`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `ID_ADMIN` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `ID_AUDIT_LOG` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `detail_panen`
--
ALTER TABLE `detail_panen`
  MODIFY `ID_DETAIL_PANEN` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `dinas`
--
ALTER TABLE `dinas`
  MODIFY `ID_DINAS` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `hasil_panen`
--
ALTER TABLE `hasil_panen`
  MODIFY `ID_PANEN` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `input_data`
--
ALTER TABLE `input_data`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `insight`
--
ALTER TABLE `insight`
  MODIFY `ID_INSIGHT` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `komoditas`
--
ALTER TABLE `komoditas`
  MODIFY `ID_KOMODITAS` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `laporan`
--
ALTER TABLE `laporan`
  MODIFY `ID_LAPORAN` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `lokasi`
--
ALTER TABLE `lokasi`
  MODIFY `ID_LOKASI` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `petugas_bangsal`
--
ALTER TABLE `petugas_bangsal`
  MODIFY `ID_PETUGAS_BANGSAL` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `reject_panen`
--
ALTER TABLE `reject_panen`
  MODIFY `ID_REJECT` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `supervisor`
--
ALTER TABLE `supervisor`
  MODIFY `ID_SUPERVISOR` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `ID_SUPPLIER` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `validasi`
--
ALTER TABLE `validasi`
  MODIFY `ID_VALIDASI` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`ID_ADMIN`) REFERENCES `admin` (`ID_ADMIN`),
  ADD CONSTRAINT `audit_log_ibfk_2` FOREIGN KEY (`ID_DINAS`) REFERENCES `dinas` (`ID_DINAS`),
  ADD CONSTRAINT `audit_log_ibfk_3` FOREIGN KEY (`ID_SUPERVISOR`) REFERENCES `supervisor` (`ID_SUPERVISOR`),
  ADD CONSTRAINT `audit_log_ibfk_4` FOREIGN KEY (`ID_PETUGAS_BANGSAL`) REFERENCES `petugas_bangsal` (`ID_PETUGAS_BANGSAL`);

--
-- Constraints for table `detail_panen`
--
ALTER TABLE `detail_panen`
  ADD CONSTRAINT `detail_panen_ibfk_1` FOREIGN KEY (`ID_PANEN`) REFERENCES `hasil_panen` (`ID_PANEN`);

--
-- Constraints for table `hasil_panen`
--
ALTER TABLE `hasil_panen`
  ADD CONSTRAINT `hasil_panen_ibfk_1` FOREIGN KEY (`ID_PETUGAS_BANGSAL`) REFERENCES `petugas_bangsal` (`ID_PETUGAS_BANGSAL`),
  ADD CONSTRAINT `hasil_panen_ibfk_2` FOREIGN KEY (`ID_KOMODITAS`) REFERENCES `komoditas` (`ID_KOMODITAS`),
  ADD CONSTRAINT `hasil_panen_ibfk_3` FOREIGN KEY (`ID_SUPPLIER`) REFERENCES `supplier` (`ID_SUPPLIER`);

--
-- Constraints for table `insight`
--
ALTER TABLE `insight`
  ADD CONSTRAINT `insight_ibfk_1` FOREIGN KEY (`ID_LAPORAN`) REFERENCES `laporan` (`ID_LAPORAN`);

--
-- Constraints for table `laporan`
--
ALTER TABLE `laporan`
  ADD CONSTRAINT `laporan_ibfk_1` FOREIGN KEY (`ID_LOKASI`) REFERENCES `lokasi` (`ID_LOKASI`);

--
-- Constraints for table `petugas_bangsal`
--
ALTER TABLE `petugas_bangsal`
  ADD CONSTRAINT `petugas_bangsal_ibfk_1` FOREIGN KEY (`ID_LOKASI`) REFERENCES `lokasi` (`ID_LOKASI`);

--
-- Constraints for table `reject_panen`
--
ALTER TABLE `reject_panen`
  ADD CONSTRAINT `reject_panen_ibfk_1` FOREIGN KEY (`ID_PANEN`) REFERENCES `hasil_panen` (`ID_PANEN`);

--
-- Constraints for table `supervisor`
--
ALTER TABLE `supervisor`
  ADD CONSTRAINT `supervisor_ibfk_1` FOREIGN KEY (`ID_LOKASI`) REFERENCES `lokasi` (`ID_LOKASI`);

--
-- Constraints for table `validasi`
--
ALTER TABLE `validasi`
  ADD CONSTRAINT `validasi_ibfk_1` FOREIGN KEY (`ID_PANEN`) REFERENCES `hasil_panen` (`ID_PANEN`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
