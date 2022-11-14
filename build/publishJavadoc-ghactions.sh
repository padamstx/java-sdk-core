#!/bin/bash

# Publish javadocs only for a tagged-release.
if [[ "${GITHUB_REF_TYPE}" == "tag" ]]; then

    printf "\n>>>>> Publishing javadoc for release build: repo=%s branch=%s build_num=%s job_num=%s\n" ${GITHUB_REPOSITORY} ${GITHUB_REF_NAME} ${GITHUB_RUN_ID} ${GITHUB_RUN_NUMBER} 

    printf "\n>>>>> Cloning repository's gh-pages branch into directory 'gh-pages'\n"
    rm -fr ./gh-pages
    git clone --branch=gh-pages https://${GH_TOKEN}@github.com/padamstx/java-sdk-core.git gh-pages

    printf "\n>>>>> Finished cloning...\n"

    pushd gh-pages
    
    # Create a new directory for this branch/tag and copy the javadocs there.
    printf "\n>>>>> Copying javadocs to new directory: docs/%s\n" ${GITHUB_REF_NAME}
    rm -rf docs/${GITHUB_REF_NAME}
    mkdir -p docs/${GITHUB_REF_NAME}
    cp -rf ../target/site/apidocs/* docs/${GITHUB_REF_NAME}

    printf "\n>>>>> Generating gh-pages index.html...\n"
    ../build/generateJavadocIndex.sh > index.html

    # Update the 'latest' symlink to point to this branch if it's a tagged release.
    if [ -n "${GITHUB_REF_NAME}" ]; then
	pushd docs
	rm latest
	ln -s ./${GITHUB_REF_NAME} latest
	printf "\n>>>>> Updated 'docs/latest' symlink:\n"
	ls -l latest
	popd
    fi

    printf "\n>>>>> Committing new javadoc...\n"
    git add -f .
    git commit -m "doc: latest javadoc for ${GITHUB_REF_NAME} (${GITHUB_SHA})"
    git push -f origin gh-pages

    popd

    printf "\n>>>>> Published javadoc for release build: repo=%s branch=%s build_num=%s job_num=%s\n"  ${GITHUB_REPOSITORY} ${GITHUB_REF_NAME} ${GITHUB_RUN_ID} ${GITHUB_RUN_NUMBER} 

else

    printf "\n>>>>> Javadoc publishing bypassed for non-release build: repo=%s branch=%s build_num=%s job_num=%s\n" ${GITHUB_REPOSITORY} ${GITHUB_REF_NAME} ${TRAVIS_BUILD_NUMBER} ${GITHUB_RUN_NUMBER} 

fi

