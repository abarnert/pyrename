#!/bin/sh

rm -rf tests
mkdir tests
cd tests

touch reg11 reg22 reg33
rename -s 1 0 -S 2 0 *
test -f reg01 || echo 'test1: reg11->reg01 failed'
test -f reg00 || echo 'test1: reg22->reg00 failed'
test 3 -eq $(ls | wc -l) || echo 'test1: wrong number of files'
rm -r *

touch noext ext.ext.e.x.t
rename -XxX -a ENSION -c *
test -f noextension || echo 'test2: noext->noextension failed'
test -f ext.extension.e.t || echo 'test2: ext.ext.e.x.t->ext.extension.e.t failed'
test 2 -eq $(ls | wc -l) || echo 'test2: wrong number of files'
rm -r *

mkdir dir
touch foo
# Note that this creates a broken link, and rename really should
# do a better job here, but we're testing its existing behavior
rename -l -e 's/(.*)/dir\/$1/' foo
test -L dir/foo && test $(readlink dir/foo) = foo || echo 'test3: foo->dir/foo link failed'
test 2 -eq $(ls | wc -l) || echo 'test3: wrong number of files'
test 1 -eq $(ls dir | wc -l) || echo 'test3: wrong number of files'
rm -r *

touch foo
# This one of course creates a working link
rename -p -L -e 's/(.*)/dir\/$1/' foo
test -d dir || echo 'test4: dir directory not created'
test -f dir/foo || echo 'test4: foo->dir/foo hardlink failed'
test 2 -eq $(ls | wc -l) || echo 'test4: wrong number of files'
test 1 -eq $(ls dir | wc -l) || echo 'test4: wrong number of files'
rm -r *

touch STUPID.DOS "Windows filename"
rename -p -c -z -X -e '$_ = "$EXT/$_" if @EXT' *
test -d dos || echo 'test5: dos directory not created'
test -f windows_filename || echo 'test5: Windows filename->windows_filename failed'
test -f dos/stupid.dos || echo 'test5: STUPID.DOS->dos/stupid.dos failed'
test 2 -eq $(ls | wc -l) || echo 'test5: wrong number of files'
test 1 -eq $(ls dos | wc -l) || echo 'test5: wrong number of files'
rm -r *

touch one_two.ext
# Without the -f, this will fail on Windows, and may also fail on Mac
rename -f -X -c --rews --camelcase --nows *
test -f One_Two.ext || echo 'test6: one_two.ext->One_Two.ext failed'
rm -r *

touch a.a z.z b.b y.y
# NOTE: This relies on filesystems with precise-enough file times
rename -N ...01 -t -X -e '$_ = "File$N"' *
test -f File1.a || echo 'test7: a.a->File1.a failed'
test -f File2.b || echo 'test7: b.b->File2.b failed'
test -f File3.y || echo 'test7: y.y->File3.y failed'
test -f File4.z || echo 'test7: z.z->File4.z failed'
rm -r *

touch U+263a white_smiling_face
# NOTE: May rely on UTF-8
# NOTE: --noctrl converting the smiling face character into %E2_%BA
# is probably a bug--and the fact that it doesn't do so if put on
# the same line as the code that emits the character makes that even
# more plausible. The weird behavior of vianame, however, is not a
# bug, that's documented by charnames.
rename -M'charnames()' --rews -C -e '$_ = charnames::vianame($_)' *
rename -z *
test -f %E2_%BA || echo 'test8: U+263a->%E2_%BA failed'
test -f 9786 || echo 'test8: white_smiling_face->9876 failed'
rm -r *
