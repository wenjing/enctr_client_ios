SQLite format 3   @                                                                     -�   �    �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Q  Qa���?                                                           �J�stableusersusersCREATE TABLE users ( 
	'user_id' 	INTEGER Primary key,
	'name'  	TEXT,
	'screenName'  	TEXT,
	'email'  	TEXT,
	'location' 	TEXT,
	'meetsCount' 	INTEGER,
	'profileImageUrl' 	TEXT
)A!Yindexusers_nameusersCREATE INDEX users_name on users(name)�2�CtablemeetsmeetsCREATE TABLE meets (
	'id'        INTEGER,
	'postId'    INTEGER,
	'userId'    INTEGER,
	'type'	    INTEGER,
	'timeAt'    INTEGER,
	'updateAt'  INTEGER,
	'longitude' TEXT,
	'latitude'  TEXT,
	'description'	TEXT,
	'source'     TEXT,
	'user_count' INTEGER,
PRIMARY KEY(id,postid,type)
))= indexsqlite_autoindex_meets_1meets;Qindexmeet_idsmeetsCREATE INDEX meet_ids on meets(id)?Yindexpost_idsmeetsCREATE INDEX post_ids on meets(postId)�>�_tablenewsnewsCREATE TABLE news (
        'id'      INTEGER,
        'odd'     INTEGER,
        'uid'     INTEGER,
        'cid'     INTEGER,
        'data'    TEXT,
PRIMARY KEY(id)
)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 	 � P����3 �                                                                                                                                                                        Q)!gindexstatistics_idsstatisticsCREATE INDEX statistics_ids on statistics(id)9Oindexnews_idsnews
CREATE INDEX news_ids on news(id)<	Sindexnews_oddsnewsCREATE INDEX news_odds on news(odd)@
#Windexcirkle_uidsnewsCREATE INDEX cirkle_uids on news(uid)@#Windexcirkle_cidsnewsCREATE INDEX cirkle_cids on news(cid)��ytablecirklescirklesCREATE TABLE cirkles (
        'id'      INTEGER,
        'odd'     INTEGER,
        'data'    TEXT,
PRIMARY KEY(id)
)C!Yindexcirkle_idscirklesCREATE INDEX cirkle_ids on cirkles(id)F#]indexcirkle_oddscirklesCREATE INDEX cirkle_odds on cirkles(odd)�J!!�_tablestatisticsstatisticsCREATE TABLE statistics (
        'id'      INTEGER,
        'odd'     INTEGER,
        'cirkle'  TEXT,
        'news'    TEXT,
        'misc'    TEXT,
PRIMARY KEY(id)
)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              