/*
 * Copyright (c) 2015 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <sys/socket.h>
#include <sys/un.h>
#include <inttypes.h>
#include <stdlib.h>
#include <errno.h>

#define LOG_TAG "motorild"

#include <cutils/log.h>
#include <cutils/properties.h>
#include <cutils/sockets.h>

#include "motoril.h"

int main(__attribute__((unused))int argc, __attribute__((unused))char **argv)
{
	int fd, client;
	struct sockaddr_un clientaddr;
	socklen_t clientlen = sizeof(clientaddr);
	struct motoril_route route;
	char cmd[256];
	unsigned int pos;
	int ret;

	ALOGI("motorild starting");

	fd = android_get_control_socket("motorild");
	if (fd < 0) {
		ALOGE("Can't get socket!");
	}

	ret = listen(fd, 10);

	while (1) {
		client = accept(fd, (struct sockaddr*)&clientaddr, &clientlen);
		if (client == -1) {
			ALOGE("accept");
			continue;
		}

		ALOGI("accepted connection");

		pos = 0;
		do {
			ret = read(client, ((uint8_t*)&route) + pos, sizeof(route) - pos);
			if (ret == 0) {
				ALOGE("connection closed");
				break;
			} else if (ret < 0) {
				ALOGE("read");
				break;
			}

			pos += ret;
		} while (pos < sizeof(route));

		if (pos < sizeof(route)) {
			close(client);
			continue;
		}

		ALOGI("IF: %s, GW: %s", route.dev, route.gw);
		memset(cmd, 0, sizeof(cmd));
		snprintf(cmd, sizeof(cmd) - 1, "/system/bin/ndc route add dst v4 %s 0 %s",
			route.dev, route.gw);

		ret = system(cmd);
		ALOGI("%s: %d", cmd, ret);

		if (ret == 0) {
			write(client, "OK", 2);
		} else {
			write(client, "KO", 2);
		}

		close(client);
	}

	return EXIT_SUCCESS;
}
