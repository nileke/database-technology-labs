<result>

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

