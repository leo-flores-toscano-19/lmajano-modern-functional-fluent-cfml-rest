component extends="tests.resources.BaseTest" appMapping="/" {

	function run() {
		describe( "Rants V3 API Handler", function() {
			beforeEach( function( currentSpec ) {
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			scenario( "Get a list of Rants", function() {
				given( "I make a get call to /api/v3/rants", function() {
					when( "I have no search filters", function() {
						then( "I will get a list of Rants", function() {
							var event = get( "/api/v3/rants" );
							var returnedJSON = event.getRenderData().data;
							//expect( structKeyExists( returnedJSON, "error" ) ).toBeTrue();
							// expect( structKeyExists( returnedJSON, "error" ) ).toBe( true );
							// expect( returnedJSON ).toHaveKey( "error" );
							//expect( returnedJSON ).toHaveKey( "errors" );
							expect( returnedJSON ).toHaveKeyWithCase( "ERROR" );
							// expect( returnedJSON ).toHaveKeyWithCase( "errors" );
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON.data ).toBeArray();
							expect( returnedJSON.data ).toHaveLengthGTE( 1 );
						} );
					} );
				} );
			} );

			scenario( "Get an individual Rant", function() {
				given( "I make a get call to /api/v3/rants/:rantID", function() {
					when( "I pass an invalid rantID", function() {
						then( "I will get a 412 error", function() {
							var rantID = "x"
							var event = get( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'RANTID' has an invalid type, expected type is numeric"
							);
						} );
					} );

					when( "I pass a valid but non existing rantID", function() {
						then( "I will get a 404 error", function() {
							var rantID = "1"
							var event = get( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toMatch( "Rant not found" );
						} );
					} );

					when( "I pass a valid and existing rantID", function() {
						then( "I will get a single Rant returned", function() {
							var rantID = 7;
							var event = get( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( event ).toHaveStatusCode( 200 );
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON.data ).toBeStruct();
							expect( returnedJSON.data ).toHaveKeyWithCase( "id" );
							expect( returnedJSON.data.id ).toBe( 7 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLength( 0 );
						} );
					} );
				} );
			} );


			scenario( "Create a Rant", function() {
				given( "I make a post call to /api/v3/rants", function() {
					when( "Using a get method", function() {
						then( "I will hit the index action instead of the create action", function() {
							var event = get( "/api/v3/rants" );
							expect( event.getCurrentAction() ).toBe(
								"index",
								"Expected to hit index action not [#event.getCurrentAction()#] action"
							);
						} );
					} );

					when( "Including no userID param", function() {
						then( "I will get a 412 error", function() {
							var event = post( "/api/v3/rants", {} );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including an empty userID param", function() {
						then( "I will get a 412 error", function() {
							var event = post( "/api/v3/rants", { "userID": "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including a non numeric userID param", function() {
						then( "I will get a 412 error", function() {
							var event = post( "/api/v3/rants", { "userID": "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'USERID' has an invalid type, expected type is numeric"
							);
						} );
					} );

					when( "Including no body param", function() {
						then( "I will get a 412 error", function() {
							var event = post( "/api/v3/rants", { "userID": "5" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including an empty body param", function() {
						then( "I will get a 412 error", function() {
							var event = post( "/api/v3/rants", { "userID": "5", "body": "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including valid userID for a non existing User", function() {
						then( "I will get a 404 error", function() {
							var event = post( "/api/v3/rants", { "body": "xsxswxws", "userID": "1" } );
							var returnedJSON = event.getRenderData().data;
							debug( returnedJSON );
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "User not found" );
						} );
					} );

					when( "I pass a valid body and userID", function() {
						then( "I will get a successful query result with a generatedKey", function() {
							var event = post( "/api/v3/rants", { "body": "xsxswxws", "userID": "5" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON.data ).toBeStruct();
							expect( returnedJSON.data ).toHaveKeyWithCase( "rantID" );
							expect( returnedJSON.data.rantID ).toBeGT( 7 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Created" );
						} );
					} );
				} );
			} );



			scenario( "Update a Rant", function() {
				given( "I make a get call to /api/v3/rants/:rantID", function() {
					when( "Using a get method", function() {
						then( "I will hit the show action instead of the update action", function() {
							var rantID = "1";
							var event = get( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"show",
								"I expect to hit show action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Using a post method", function() {
						then( "I will hit the show action instead of the update action", function() {
							var rantID = "1";
							var event = post( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"onInvalidHTTPMethod",
								"I expect to hit onInvalidHTTPMethod action instead of the update action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Including no userID param", function() {
						then( "I will get a 412 error", function() {
							var rantID = "7";
							var event = put( "/api/v3/rants/#rantID#", {} );
							var returnedJSON = event.getRenderData().data;
							debug( returnedJSON );
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including an empty userID param", function() {
						then( "I will get a 412 error", function() {
							var rantID = "7";
							var event = put( "/api/v3/rants/#rantID#", { "userID": "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'USERID' value is required" );
						} );
					} );

					when( "Including a non numeric userID param", function() {
						then( "I will get a 412 error", function() {
							var rantID = "7";
							var event = put( "/api/v3/rants/#rantID#", { "userID": "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'USERID' has an invalid type, expected type is numeric"
							);
						} );
					} );


					when( "Including no body param", function() {
						then( "I will get a 412 error", function() {
							var rantID = "1";
							var event = put( "/api/v3/rants/#rantID#", { "userID": "1" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including an empty body param", function() {
						then( "I will get a 412 error", function() {
							var rantID = "1";
							var event = put( "/api/v3/rants/#rantID#", { "userID": "1", "body": "" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "The 'BODY' value is required" );
						} );
					} );

					when( "Including a non numeric rantID param", function() {
						then( "I will get a 412 error", function() {
							var rantID = "abc";
							var event = put( "/api/v3/rants/#rantID#", { "userID": "1", "body": "abc" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'RANTID' has an invalid type, expected type is numeric"
							);
						} );
					} );

					when( "Including valid userID for a non existing User", function() {
						then( "I will get a 404 error", function() {
							var rantID = "7";
							var event = put( "/api/v3/rants/#rantID#", { "body": "xsxswxws", "userID": "1" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "User not found" );
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function() {
						then( "I will get a 404 error", function() {
							var rantID = "1";
							var event = put( "/api/v3/rants/#rantID#", { "userID": "5", "body": "xsxswxws" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant not found" );
						} );
					} );

					when( "I pass a valid body and userID and rantID", function() {
						then( "I will update the Rant Successfully", function() {
							var rantID = "7";
							var event = put( "/api/v3/rants/#rantID#", { "body": "xsxswxws", "userID": "5" } );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeFalse();
							expect( event.getStatusCode() ).toBe( 200 );
							expect( returnedJSON ).toHaveKeyWithCase( "data" );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant Updated" );
						} );
					} );
				} );
			} );


			scenario( "Delete a Rant", function() {
				given( "I make a get call to /api/v3/rants/:rantID", function() {
					when( "Using a get method", function() {
						then( "I will hit the show action instead of the update action", function() {
							var rantID = "1";
							var event = get( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"show",
								"I expect to hit show action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Using a post method", function() {
						then( "I will hit the show action instead of the update action", function() {
							var rantID = "1";
							var event = post( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"onInvalidHTTPMethod",
								"I expect to hit onInvalidHTTPMethod action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Including a space for rantID param", function() {
						then( "I will hit the index action instead of the delete action", function() {
							var rantID = " ";
							var event = get( "/api/v3/rants/#rantID#" );
							expect( event.getCurrentAction() ).toBe(
								"index",
								"I expect to hit index action instead of the delete action due to the VERB, but I actually hit [#event.getCurrentAction()#]"
							);
						} );
					} );

					when( "Including a non numeric rantID param", function() {
						then( "I will get a 412 error", function() {
							var rantID = "abc";
							var event = delete( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 412 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe(
								"The 'RANTID' has an invalid type, expected type is numeric"
							);
						} );
					} );

					when( "Including valid rantID for a non existing Rant", function() {
						then( "I will get a 404 error", function() {
							var rantID = 1;
							var event = delete( "/api/v3/rants/#rantID#" );
							var returnedJSON = event.getRenderData().data;
							expect( returnedJSON ).toHaveKeyWithCase( "error" );
							expect( returnedJSON.error ).toBeTrue();
							expect( event ).toHaveStatusCode( 404 );
							expect( returnedJSON ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON.messages ).toBeArray();
							expect( returnedJSON.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON.messages[ 1 ] ).toBe( "Rant not found" );
						} );
					} );

					when( "I pass a valid rantID", function() {
						then( "I will delete the rant successfully", function() {
							var event = post( "/api/v3/rants", { "body": "New Rant Created to Delete", "userID": "5" } );
							var returnedJSON = event.getRenderData().data;
							debug( returnedJSON );
							setup();
							var rantID = returnedJSON.data.rantID;
							var event2 = delete( "/api/v3/rants/#rantID#" );

							var returnedJSON2 = event2.getRenderData().data;
							expect( returnedJSON2 ).toHaveKeyWithCase( "error" );
							expect( returnedJSON2.error ).toBeFalse();
							expect( event2.getStatusCode() ).toBe( 200 );
							expect( returnedJSON2 ).toHaveKeyWithCase( "data" );
							expect( returnedJSON2 ).toHaveKeyWithCase( "messages" );
							expect( returnedJSON2.messages ).toBeArray();
							expect( returnedJSON2.messages ).toHaveLengthGTE( 1 );
							expect( returnedJSON2.messages[ 1 ] ).toBe( "Rant Deleted" );
						} );
					} );
				} );
			} );
		} );
	}

}
