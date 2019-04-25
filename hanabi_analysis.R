rm(list=ls())
library(xtable)
library(corrplot)
library(multcomp)

#####################################################################
##################     DESCRIPTIVE STATISTICS   #####################
#####################################################################

part <- read.csv("participants.csv")
head(part)
names(part)
dim(part)
summary(part[,c(4,1:2,8,6,10,9,3,5)])

## $N = 224$ participants, only $N_c = 171$ gave complete answers to the
## questionnaire (i.e. $N_m$ = 53 questionnaires with missing values).

## Extract observations with missing values:
compl<-part[complete.cases(part),-c(1,14)]
compl$ai<-as.numeric(compl$ai)
compl$age<-as.numeric(compl$age)
compl$gamer<-as.numeric(compl$gamer)

M <- cor(compl[,c(3,1:2,4:12)])
corrplot(M, method="circle") ### simple correlations! not conditionals

### Hanabiexp, recent and maxscore seem to correlate highly
### Intention, skill and like seem to correlate highly
### gamer and boardgameexp seem to correlate highly

levels(part$ai)[1]<-"full"
levels(part$ai)[2]<-"intentional"
levels(part$ai)[3]<-"base.outer"
part$ai<-relevel(part$ai, "base.outer")

#####################################################################
##################           PERFORMANCE        #####################
#####################################################################

### Mod 1: What you suggested:
mod1<-lm(score~factor(ai)+factor(hanabiexp)+
           factor(boardgameexp)+factor(maxscore)+
           factor(recent), data=part)
anova(mod1)  ## no effect of hanabiexp, boardgameexp, maxscore or recent on score

## Multiple testing:
amod <- aov(score~ai+factor(hanabiexp)+
              factor(boardgameexp)+factor(maxscore)+
              factor(recent), data=part)
tuk <- glht(amod, linfct = mcp(ai = "Tukey"))
tuk.cld <- cld(tuk)
old.par <- par(mai=c(1,1,1.25,1), no.readonly=TRUE)
plot(tuk.cld, ylab="Scores") ### conditional on hanabiexp, boardgameexp, maxscore or recent on score 
par(old.par) ## a and a means they are not sig different, b and b are not sig diff.
## Intentional is not sign different from full in this case.

### Other perspective:
### Mod 2: Complete model (include all variables)
mod2<-lm(score~factor(ai)+factor(deck)+factor(age)+
           factor(boardgameexp)+factor(gamer)+factor(hanabiexp)+
           factor(recent)+factor(maxscore)+factor(intention)+
           factor(skill)+factor(like), data=part)
anova(mod2)  

### Mod 3: Significant variables from complete model + interactions
mod3<-lm(score~factor(ai)*factor(hanabiexp)*
           factor(intention)*factor(skill), data=part)
anova(mod3) ## interactions are not significant

### Mod 4: What matters:
mod4<-lm(score~factor(ai)+factor(intention)+factor(skill), data=part)
anova(mod4)
summary(mod4)
part$ai<-factor(part$ai)

### Multiple testing:
amod <- aov(score~ai+factor(intention)+factor(skill), data=part)
tuk <- glht(amod, linfct = mcp(ai = "Tukey"))
tuk.cld <- cld(tuk)
old.par <- par(mai=c(1,1,1.25,1), no.readonly=TRUE)
plot(tuk.cld, ylab="Scores") ### conditional on intention and skill, 
par(old.par) ## a and a means they are not sig different, b is.
## Intentional is sign different from the others, controlling for intention and skill.

#####################################################################
##################           ACCEPTANCE         #####################
#####################################################################

library(reshape)

names(part)
compl<-part[complete.cases(part),c(2,11:13)]
mytable <- data.frame(compl) 
aa<-melt(mytable,id=c("ai","intention","skill"))
bb<-cast(aa,ai~skill,sum)
cc<-cast(aa,ai~intention,sum)

### there are no enough values for skill = 5 or intention = 1 or 5, so 
### I will equate skill  = 5 to skill = 4 and 
### intention = 1 to intention =2 and intention =5 to intention =4
### I will work with the sum of like per category:

head(compl)
compl[compl$skill==5,]$skill<-4
compl[compl$intention==5,]$intention<-4
compl[compl$intention==1,]$intention<-2
summary(compl)

aa<-melt(compl,id=c("ai","intention","skill"))
bb1<-cast(aa,ai~skill,sum)
chisq.test(bb1) ### sum of like per AI and Skill are independent. 
mosaicplot(bb1, color=T,main="Skill") 
bb2<-cast(aa,ai~intention,sum)
chisq.test(bb2) ### sum of like per AI and intention are independent.
mosaicplot(bb2, color=T,main="Intention")

#####################################################################
##################           REPETITIONS        #####################
#####################################################################

rm(list=ls())
games <- read.csv("games.csv")
head(games)
names(games)

dat<-games[,c("id","ai","score","time")]
summary(dat)

NN<-170 ## maximum # of games per player per AI
full<-matrix(0,224,NN)
for(i in 1:224){
  out<-as.vector(games[games$id==levels(games$id)[i]&
                       games$ai==levels(games$ai)[1],]$score)
  pr<-ifelse(length(out)==0,next,1)
  full[i,]<-c(out,rep("NA",NN-length(out)))
}

inte<-matrix(0,224,NN)
for(i in 1:224){
  out<-as.vector(games[games$id==levels(games$id)[i]&
                         games$ai==levels(games$ai)[2],]$score)
  pr<-ifelse(length(out)==0,next,1)
  inte[i,]<-c(out,rep("NA",NN-length(out)))
}

outer<-matrix(0,224,NN)
for(i in 1:224){
  out<-as.vector(games[games$id==levels(games$id)[i]&
                         games$ai==levels(games$ai)[3],]$score)
  pr<-ifelse(length(out)==0,next,1)
  outer[i,]<-c(out,rep("NA",NN-length(out)))
}

par(mfrow=c(3,1))
matplot(t(full),type='l', main="Full",ylim=c(0,25))
matplot(t(inte),type='l', main="Intentional",ylim=c(0,25))
matplot(t(outer),type='l', main="Outer",ylim=c(0,25))

### seems like it doesn't!
## let's check the numbers:

games$id<-as.numeric(games$id)
games$time<-games$time-min(games$time)
newd<-games[,-c(3,5,6)]
head(games[order(newd$id),])
aa<-lm(score~factor(ai)*time+factor(id), data=games)
anova(aa)
summary(aa)

round(aa$coefficients[c(1:4,228:229)],9)
### controlling by player and AI, when time increases (I'm 
### assuming this is the case of more games) then the score 
### DECREASES significantly (the coefficient is negative)