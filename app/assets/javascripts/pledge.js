	// http://stackoverflow.com/questions/46155/validate-email-address-in-javascript
	var validateEmail = function validateEmail(email) {
		var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
		return re.test(email);
	};

	window.onload = function() {
		var pledgeAmount = document.querySelector(".pledge-amount");
		var pledgeForm = document.querySelector("#new_user");

		pledgeAmount.addEventListener("input", function() {
			var pledge = Number(pledgeAmount.value);
			var pledgePerWeekElement = document.querySelector(".pledge-per-week");

			if(isNaN(pledge)) {
				pledgePerWeekElement.innerHTML = "an invalid amount";
			} else {
				pledgePerWeekElement.innerHTML = "$" + (pledge * .49).toFixed(2);
			}
		}, false);

		pledgeForm.addEventListener("submit", function(event) {
			var pledgeAmount = Number(document.querySelector(".pledge-amount").value);
			var pledgeLimit = Number(document.querySelector(".pledge-limit").value);
			var pledgeLimitStatus = document.querySelector("input[name=limit]:checked").value;
			var pledgeSubmit = document.querySelector("#pledgeSubmit");
			var email = document.querySelector("#user_email_address").value;
			var initialValidation = true;
			var showError = function showError(error) {
				document.querySelector(".stripe-error").innerHTML = error;
			}

			event.preventDefault();
			pledgeSubmit.disabled = true;

			if(!validateEmail(email)) {
				initialValidation = false;
				showError("Please provide a valid email address.");
			}

			if(pledgeAmount <= 0) {
				initialValidation = false;
				showError("You must pledge at least 1&cent;.");
			}

			if(pledgeLimitStatus === "true" && pledgeLimit <= 0) {
				initialValidation = false;
				showError("Your pledge limit must be at least $1.");
			}

			if(initialValidation) {		
				document.querySelectorAll(".rails-error").forEach(function(errorField) {
					errorField.innerHTML = "";
				});
	
				Stripe.card.createToken({
					number: document.querySelector("#cc_number").value,
					cvc: document.querySelector("#cvc").value,
					exp_year: document.querySelector("#exp_year").value,
					exp_month: document.querySelector("#exp_month").value
				}, 
				1, 
				function(status, response) {
					var stripeToken;

					if(status === 200) {
						stripeToken = document.createElement("input");
						stripeToken.type = "hidden";
						stripeToken.name = "stripe_token";
						stripeToken.value = response.id;
						pledgeForm.appendChild(stripeToken);

						pledgeForm.submit();
					} else {
						showError(response.error.message);
						pledgeSubmit.disabled = false;
					}
				});
			} else {
				pledgeSubmit.disabled = false;
			}
		}, false);
	};