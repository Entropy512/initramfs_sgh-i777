#!/sbin/sh
#
# Copyright (C) 2011 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Library General Public License as published
# by the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
# USA.
#
# License GPLv2+: GNU GPL version 2 or later <http://gnu.org/licenses/gpl.html>
#
#################################
# BonsaiROM
#################################

MMC=`ls -d /sys/block/mmc*`
SCHEDULER=bfq

# Optimize non-rotating storage; 
log "INIT.scheduler BEGIN:setting scheduler parameters for $SCHEDULER"

case "$SCHEDULER" in

  noop)
    for i in $MMC; do
      echo "noop" > $i/queue/scheduler
    done
  ;;

  deadline)
    for i in $MMC; do
      echo "deadline" > $i/queue/scheduler
      echo 80 > $i/queue/iosched/read_expire # untested
      echo 1 > $i/queue/iosched/fifo_batch   # untested
      echo 1 > $i/queue/iosched/front_merges # untested
    done
    ;;

  cfq)
    for i in $MMC; do
      echo "cfq" > $i/queue/scheduler
      echo "0" > $i/queue/rotational
      echo "1" > $i/queue/iosched/back_seek_penalty
      echo "1" > $i/queue/iosched/low_latency
      echo "3" > $i/queue/iosched/slice_idle
      echo "4096" > $i/queue/read_ahead_kb	# default: 128; (recomended: 128)
      echo 1000000000 > $i/queue/iosched/back_seek_max
      echo "16" > $i/queue/iosched/quantum    # default: 4 (recomended: 16)  
      echo "2048" > $i/queue/nr_requests	# default:128 (recomended: 2048) 
    done

    echo "0" > /proc/sys/kernel/sched_child_runs_first
  ;;

  bfq)
    for i in $MMC; do
      echo "bfq" > $i/queue/scheduler
      echo "0" > $i/queue/rotational
      echo "1" > $i/queue/iosched/back_seek_penalty
      echo "3" > $i/queue/iosched/slice_idle
      echo "2048" > $i/queue/read_ahead_kb	# default: 128
      echo 1000000000 > $i/queue/iosched/back_seek_max
      echo "16" > $i/queue/iosched/quantum    # default: 4 (recomended: 16)  
      echo "2048" > $i/queue/nr_requests	# default:128 (recomended: 2048) 
    done
  ;;

  *)
    log "INIT.scheduler ERROR:failed to set parameters for unknown scheduler: $SCHEDULER"
    exit -1;
  ;;
esac

log "INIT.scheduler END:setting $SCHEDULER scheduler  parameters"
