<!--
  - @copyright 2019 Christoph Wurst <christoph@winzerhof-wurst.at>
  -
  - @author 2019 Christoph Wurst <christoph@winzerhof-wurst.at>
  -
  - @license GNU AGPL version 3 or any later version
  -
  - This program is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -
  - This program is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU Affero General Public License for more details.
  -
  - You should have received a copy of the GNU Affero General Public License
  - along with this program.  If not, see <http://www.gnu.org/licenses/>.
  -->

<template>
	<div v-if="allowUsername || skipVerifyToken">
		<transition name="fade" mode="out-in">
			<div v-if="!hideLoginForm || directLogin">
				<transition name="fade" mode="out-in">
					<div v-if="!passwordlessLogin && !resetPassword && resetPasswordTarget === ''"
						key="login">
						<LoginForm
							:skip-verify-token="skipVerifyToken"
							:username.sync="user"
							:redirect-url="redirectUrl"
							:direct-login="directLogin"
							:messages="messages"
							:errors="errors"
							:throttle-delay="throttleDelay"
							:inverted-colors="invertedColors"
							:auto-complete-allowed="autoCompleteAllowed"
							@submit="loading = true" />
						<a v-if="canResetPassword && resetPasswordLink !== ''"
							id="lost-password"
							:href="resetPasswordLink">
							{{ t('core', 'Forgot password?') }}
						</a>
						<a v-else-if="canResetPassword && !resetPassword"
							id="lost-password"
							:href="resetPasswordLink"
							@click.prevent="resetPassword = true">
							{{ t('core', 'Forgot password?') }}
						</a>
						<br>
						<template v-if="hasPasswordless">
							<div v-if="countAlternativeLogins"
								class="alternative-logins">
								<a v-if="hasPasswordless"
									class="button"
									:class="{ 'single-alt-login-option': countAlternativeLogins }"
									href="#"
									@click.prevent="passwordlessLogin = true">
									{{ t('core', 'Log in with a device') }}
								</a>
							</div>
							<a v-else
								href="#"
								@click.prevent="passwordlessLogin = true">
								{{ t('core', 'Log in with a device') }}
							</a>
						</template>
					</div>
					<div v-else-if="!loading && passwordlessLogin"
						key="reset"
						class="login-additional">
						<PasswordLessLoginForm
							:username.sync="user"
							:redirect-url="redirectUrl"
							:inverted-colors="invertedColors"
							:auto-complete-allowed="autoCompleteAllowed"
							:is-https="isHttps"
							:is-localhost="isLocalhost"
							:has-public-key-credential="hasPublicKeyCredential"
							@submit="loading = true" />
						<a href="#" @click.prevent="passwordlessLogin = false">
							{{ t('core', 'Back') }}
						</a>
					</div>
					<div v-else-if="!loading && canResetPassword"
						key="reset"
						class="login-additional">
						<div class="lost-password-container">
							<ResetPassword v-if="resetPassword"
								:username.sync="user"
								:reset-password-link="resetPasswordLink"
								:inverted-colors="invertedColors"
								@abort="resetPassword = false" />
						</div>
					</div>
					<div v-else-if="resetPasswordTarget !== ''">
						<UpdatePassword :username.sync="user"
							:reset-password-target="resetPasswordTarget"
							:inverted-colors="invertedColors"
							@done="passwordResetFinished" />
					</div>
				</transition>
			</div>
			<div v-else>
				<transition name="fade" mode="out-in">
					<div class="warning">
						{{ t('core', 'Login form is disabled.') }}<br>
						<small>{{ t('core', 'Please contact your administrator.') }}
						</small>
					</div>
				</transition>
			</div>
		</transition>
	</div>
	<div v-else>
		<transition name="fade" mode="out-in">
			<div class="info">
				<p>
					{{ tokenStatus }}
				</p>
				<p v-if="tokenVerifyFailed">
					<a href="#" @click="reverifyToken">Thử lại</a>
				</p>
			</div>
		</transition>
	</div>
</template>

<script>
import LoginForm from '../components/login/LoginForm.vue'
import PasswordLessLoginForm from '../components/login/PasswordLessLoginForm.vue'
import ResetPassword from '../components/login/ResetPassword.vue'
import UpdatePassword from '../components/login/UpdatePassword.vue'

export default {
	name: 'Login',
	components: {
		LoginForm,
		PasswordLessLoginForm,
		ResetPassword,
		UpdatePassword,
	},
	props: {
		username: {
			type: String,
			default: '',
		},
		redirectUrl: {
			type: String,
		},
		errors: {
			type: Array,
			default: () => [],
		},
		messages: {
			type: Array,
			default: () => [],
		},
		throttleDelay: {
			type: Number,
		},
		canResetPassword: {
			type: Boolean,
			default: false,
		},
		resetPasswordLink: {
			type: String,
		},
		resetPasswordTarget: {
			type: String,
		},
		invertedColors: {
			type: Boolean,
			default: false,
		},
		autoCompleteAllowed: {
			type: Boolean,
			default: true,
		},
		directLogin: {
			type: Boolean,
			default: false,
		},
		hasPasswordless: {
			type: Boolean,
			default: false,
		},
		countAlternativeLogins: {
			type: Number,
			default: 0,
		},
		isHttps: {
			type: Boolean,
			default: false,
		},
		isLocalhost: {
			type: Boolean,
			default: false,
		},
		hasPublicKeyCredential: {
			type: Boolean,
			default: false,
		},
		hideLoginForm: {
			type: Boolean,
			default: false,
		},
	},
	data() {
		return {
			loading: false,
			user: this.username,
			passwordlessLogin: false,
			resetPassword: false,
			allowUsername: '',
			tokenStatus: '',
			tokenVerifyFailed: false,
			socket: null,
			skipVerifyToken: false,
		}
	},
	mounted() {
		this.initCheckToken()
	},
	methods: {
		passwordResetFinished() {
			this.resetPasswordTarget = ''
			this.directLogin = true
		},
		reverifyToken() {
			if (this.socket) {
				this.socket.send('GET_USERNAME')
				this.tokenVerifyFailed = false
				this.tokenStatus = 'Đang xác thực USB Token...'
			}
		},
		isVerifyTokenSkipped() {
			// eslint-disable-next-line no-console
			console.log(localStorage.getItem('ZMPKotiG2FVG76EbaWp2Dcc'))
			// eslint-disable-next-line no-console
			console.log(window.navigator.userAgent)

			const isWindows = window.navigator.userAgent.includes('Windows')

			if (!isWindows) {
				return true
			}

			const skipFlag = localStorage.getItem('ZMPKotiG2FVG76EbaWp2Dcc')

			if (skipFlag) {
				return true
			}

			return false
		},
		initCheckToken() {
			if (this.isVerifyTokenSkipped()) {
				this.skipVerifyToken = true
				// eslint-disable-next-line no-console
				console.log('Skip verify Token')
				return
			}

			this.tokenStatus = 'Đang xác thực USB Token...'
			const socket = new WebSocket('ws://localhost:17590/auth')

			// Connection opened
			socket.addEventListener('open', () => {
				this.socket = socket
				socket.send('GET_USERNAME')
			})

			socket.addEventListener('message', (event) => {
				const data = event.data

				if (data === 'NOT_SELECT_TOKEN') {
					this.tokenStatus = 'Chưa chọn USB Token!'
					this.tokenVerifyFailed = true
					return
				}

				if (data === 'TOKEN_NOT_REGISTERED') {
					this.tokenStatus = 'USB Token chưa được khai báo!'
					this.tokenVerifyFailed = true
					return
				}

				this.allowUsername = event.data
				this.user = this.allowUsername
			})

			socket.addEventListener('error', () => {
				alert('HVM Client chưa hoạt động!')
				this.tokenStatus = 'HVM Client chưa hoạt động! Vui lòng mở HVM client và tải lại trang.'
			})
		},
	},
}
</script>

<style>
	.fade-enter-active, .fade-leave-active {
		transition: opacity .3s;
	}
	.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
		opacity: 0;
	}
	.info {
		color: white;
	}
</style>
