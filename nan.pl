#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojo::UserAgent;
use Encode qw(decode encode);
# Fine grained response handling (dies on connection errors)
my $ua  = Mojo::UserAgent->new;
my $res = $ua->get('https://example.com/')->result;
if ($res->is_success)  {
	# Scrape the latest headlines from a news site
	my $collc = $ua->get('https://example.com/')->result->dom->find('h5[class*="xt-post-title"]');
	my $count = 1;
	my @elements = $collc->each;
	for (@elements) {
		if($count==15) {
			# Inorder not to re-enter previously entered post
			last;
		}
		my $dom = Mojo::DOM->new($_);
		# Fetch Individual Page
		my $title = do {local $/ = ''; $dom->at('a')->text};
		$title =~ s/[^\x00-\x7f]//g;
		if($title eq "French police officer sacrifices self in terror attack") {next;}
		say "Working on " . $title . "\n\n";
		eval {
    	my $image = do {local $/ = ''; $ua->get($dom->at('a')->attr('href'))->result->dom->find('img[class*="size-full"]')->first->attr('src');};
		$image =~ s/[^\x00-\x7f]//g;
		my $postText = do {local $/ = ''; $ua->get($dom->at('a')->attr('href'))->result->dom->find('div[class*="post-body"] p')->map('text')->join("\n\n")};
		$postText =~ s/[^\x00-\x7f]//g;
		my $cleanStr = $postText;
		$cleanStr =~ s/'//g;
		my @tags = split(/\n\n/, $cleanStr);
my $adsense = <<BENZ;
PLACE ADSENSE CODE HERE
BENZ
		my $lengthOfArray = scalar @tags;
		
		if($lengthOfArray<= 5) {
			;
		} else {
			# Let's insert Adsense Code in the middle of the Post Array
			splice @tags, 5, 0, $adsense;  # Insert at position 1, replace 0 elements.
			$postText = join("\n\n", @tags);
		}
		
		my $tagsStr = "";
		
		my $content = "![".$title."](".$image.")" . "<br />" . $postText . "\n\n\n";
		system 'curl -H "Authorization: Bearer put your bearer token here"
						--data "title='.$title.'&content='.$content.'&_uid=1&cid=3"
						-d "'.$tagsStr.'"
						https://mysite.com/api/v1/topics';
						
		} or do {
			my $e = $@;
    		print("Something went wrong, Going Next: $e\n");
    		next;
		};
		say "\n";
		$count++;
	}
} elsif ($res->is_error)    {
	say $res->message;
} elsif ($res->code == 301) {
	say $res->headers->location;
} else {
	say 'Nothing Found';
}