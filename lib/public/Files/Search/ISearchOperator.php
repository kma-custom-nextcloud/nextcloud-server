<?php
/**
 * @copyright Copyright (c) 2017 Robin Appelman <robin@icewind.nl>
 *
 * @author Robin Appelman <robin@icewind.nl>
 *
 * @license GNU AGPL version 3 or any later version
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
namespace OCP\Files\Search;

/**
 * @since 12.0.0
 */
interface ISearchOperator {
	/**
	 * Get a query builder hint by name
	 *
	 * @param string $name
	 * @param $default
	 * @return mixed
	 * @since 23.0.0
	 */
	public function getQueryHint(string $name, $default);

	/**
	 * Get a query builder hint
	 *
	 * @param string $name
	 * @param $value
	 * @since 23.0.0
	 */
	public function setQueryHint(string $name, $value): void;
}
