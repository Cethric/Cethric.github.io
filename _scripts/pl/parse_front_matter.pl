use CPAN::Meta::YAML;
$filename = $ARGV[0];

open $fh, "<:utf8", $filename;
$contents = do { local $/; <$fh> };

#print "Contents: $contents\n";

my ($front_matter_text) = ($contents =~ m/\G---\r*\n([-\r\na-z0-9: \"\[\],\<\>\!\_\'\+]*)\r*\n---/mi);

#print "Front Matter Text: $front_matter_text\n";

$yaml = CPAN::Meta::YAML->read_string($front_matter_text)
or die CPAN::Meta::YAML->errstr;

$front_matter_yaml = $yaml->[0];

@categories = @{$front_matter_yaml->{categories}};
@tags = @{$front_matter_yaml->{tags}};

foreach $category (@categories) {
    print "Category: $category\n"
}

foreach $tag (@tags) {
    print "Tag: $tag\n"
}