#!/bin/bash
f=$1; cmp -s /tmp/v11u406law/probe/$f /tmp/v11u406ver/probe/$f && echo "same $f" || echo "DIFF $f"
