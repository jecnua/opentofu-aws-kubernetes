fmt-all:
	terraform fmt -recursive modules/nodes/*.tf
	terraform fmt -recursive modules/controllers/*.tf

checks: # 59
	tfsec .