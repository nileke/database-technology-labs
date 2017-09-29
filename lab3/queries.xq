<result>

	<answer>


	{ (: 1. Which movies have the genre “special”? :)
		let $nl := "&#10;"
		for $x in doc("videos.xml")/result/videos/video
		where $x/genre="special"
		return ($nl,' ', $x/title)
	}	

	</answer>

	<answer>

	{ (: 2. Which director has directed at least two movies, and which movies has he directed? :)
		let $videos := doc("videos.xml")/result/videos/video
		let $nl := "&#10;"
		let $directors:=distinct-values($videos/director)
		for $d in $directors
		where count($videos[director=$d])>=2
		return <movie director="{$d}">
			{ for $v in $videos[director=$d]
				return ($nl, '  ', $v/title)
			} </movie>
	}

	</answer>

	<answer>

	{ (: 3. Which are the top ten recommended movies? :)
		let $videos  := doc("videos.xml")/result/videos/video
		let $nl := "&#10;"
		let $rating := $videos/user_rating
		let $topten :=
			for $v at $count in $videos
			where $count < 11
			order by $v/user_rating descending
			return $v
		for $t in $topten
		return concat($nl, ' ', $t/title)
	}

	
	</answer>

	<answer>

	{(: 4. Which actors have starred in the most movies? :)
		let $nl := "&#10;"
		let $doc := doc("videos.xml")/result
		let $videos := $doc/videos/video
		let $actorname := $doc/actors/actor
		let $actorcount :=
		for $actor in $actorname
			let $count := count($videos[actorRef = $actor/@id])
			where $actor/@id = $videos/actorRef
			return $count

		let $max := max($actorcount)
		for $actor in $actorname
			let $count := count($videos[actorRef = $actor/@id])
			where $actor/@id = $videos/actorRef 
			where $count = $max

		return concat($nl, 'actor=', <title>"{$actor/text()}"</title>)
	}


	</answer>

	<answer>

	{ (: 5. Which is one of the highest rating movie starring both Brad Pitt and Morgan Freeman? :)
		let $doc := doc("videos.xml")
		let $actors := $doc/result/actors/actor
		let $videos := $doc/result/videos/video
		
		let $maxrating :=
			for $v in $videos
			where $v/actorRef="916503208" and $v/actorRef="916503209"
			return $v/user_rating

		let $max := max($maxrating)
		for $v in $videos 
			where $v/actorRef="916503208" and $v/actorRef="916503209"
			where $v/user_rating = $max
			return $v/title
	}

	</answer>

	<answer>
	
	{ (: 6. Which actors have starred in a PG-13 movie between 1997 and 2006 (including 1997 and 2006)? :)
		let $doc := doc("videos.xml")
		let $actors := $doc/result/actors
		let $video := $doc/result/videos/video[rating='PG-13']
		let $nl := "&#10;"
		for $actor in $actors/actor
			where $video[year>=1997] and $video[year<=2006]
			where $actor/@id = $video/actorRef
			return concat($nl, ' ', $actor)

	}

	</answer>

	<answer>

		{ (: 7. Who have starred in the most distinct types of genre? :)
			let $doc := doc("videos.xml")
			let $video := $doc//videos/video
			let $actors := $doc//actors/actor
			let $nl := "&#10;"

			let	$allactors := 
				for $actor in $actors
					return 	<actor> { (
					  			$actor, 
					  			<genre> { 
					  				count(distinct-values(
					  				for $v in $video
						  				where $v/actorRef = $actor/@id
						  				return $v/genre)) }
					  			</genre>
					  			) }
				  			</actor>
			for $actor in $allactors
			where max($allactors/genre) = $actor/genre
			return concat($nl, 'actor=', $actor/actor/text())
		}

	</answer>

	<answer>

	{ (: 8. Which director have the highest sum of user ratings? :)
		let $doc := doc("videos.xml")/result
		let $video := $doc/videos/video
		let $directors := $video/director

		let	$alldirectors := 
			for $d in distinct-values($directors)
				return 	<director> { 
				  			$d, 
				  			<user_rating> { 
				  				sum(
				  				for $v in $video
					  				where $v/director = $d
					  				return $v/user_rating) }
				  			</user_rating>
				  			 }
			  			</director>
		for $director in $alldirectors
		where max($alldirectors/user_rating) = $director/user_rating
		return $director/text()
	}


	</answer>

	<answer>

		{ (: 9 .Which movie should you recommend to a customer if they want to see a horror movie and do not have a laserdisk? :)
			let $doc := doc("videos.xml")/result
			let $video := $doc/videos/video

			for $v in $video
				where $v/genre = 'horror'
				where $v/vhs_stock > 0
				return $v//title
		}

	</answer>

	<answer>

	{ (: 10. Group the movies by genre and sort them by user rating within each genre. :)
		let $doc := doc("videos.xml")/result
		let $video := $doc/videos/video
		let $nl := "&#10;"

		let $allgenres :=
			for $g in distinct-values($video/genre)
				return <genre genre="{$g}"> {
							let $genremovie :=
							for $v in $video
								where $v/genre = $g
								order by $v/user_rating descending
								return $v/title
							return $genremovie
				} </genre>		
		return $allgenres
	}

	</answer>


</result>

