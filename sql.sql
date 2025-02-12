
CREATE TABLE `skowix_antymulciak` (
  `id` int NOT NULL,
  `discord` varchar(255) NOT NULL,
  `license` varchar(255) NOT NULL,
  `steam` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `skowix_antymulciak`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `skowix_antymulciak`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;
COMMIT;